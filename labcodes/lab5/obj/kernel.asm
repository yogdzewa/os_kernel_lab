
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
c0100039:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 54 61 1a c0       	mov    $0xc01a6154,%eax
c0100041:	2d 00 30 1a c0       	sub    $0xc01a3000,%eax
c0100046:	83 ec 04             	sub    $0x4,%esp
c0100049:	50                   	push   %eax
c010004a:	6a 00                	push   $0x0
c010004c:	68 00 30 1a c0       	push   $0xc01a3000
c0100051:	e8 8e b2 00 00       	call   c010b2e4 <memset>
c0100056:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c0100059:	e8 79 16 00 00       	call   c01016d7 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005e:	c7 45 f4 80 b4 10 c0 	movl   $0xc010b480,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100065:	83 ec 08             	sub    $0x8,%esp
c0100068:	ff 75 f4             	pushl  -0xc(%ebp)
c010006b:	68 9c b4 10 c0       	push   $0xc010b49c
c0100070:	e8 d3 02 00 00       	call   c0100348 <cprintf>
c0100075:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c0100078:	e8 9e 08 00 00       	call   c010091b <print_kerninfo>

    grade_backtrace();
c010007d:	e8 8b 00 00 00       	call   c010010d <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100082:	e8 a6 54 00 00       	call   c010552d <pmm_init>

    pic_init();                 // init interrupt controller
c0100087:	e8 8f 1f 00 00       	call   c010201b <pic_init>
    idt_init();                 // init interrupt descriptor table
c010008c:	e8 f0 20 00 00       	call   c0102181 <idt_init>

    vmm_init();                 // init virtual memory management
c0100091:	e8 bc 7f 00 00       	call   c0108052 <vmm_init>
    proc_init();                // init process table
c0100096:	e8 c0 a2 00 00       	call   c010a35b <proc_init>
    
    ide_init();                 // init ide devices
c010009b:	e8 7d 17 00 00       	call   c010181d <ide_init>
    swap_init();                // init swap
c01000a0:	e8 21 68 00 00       	call   c01068c6 <swap_init>

    clock_init();               // init clock interrupt
c01000a5:	e8 b0 0d 00 00       	call   c0100e5a <clock_init>
    intr_enable();              // enable irq interrupt
c01000aa:	e8 d4 1e 00 00       	call   c0101f83 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000af:	e8 46 a4 00 00       	call   c010a4fa <cpu_idle>

c01000b4 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b4:	55                   	push   %ebp
c01000b5:	89 e5                	mov    %esp,%ebp
c01000b7:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000ba:	83 ec 04             	sub    $0x4,%esp
c01000bd:	6a 00                	push   $0x0
c01000bf:	6a 00                	push   $0x0
c01000c1:	6a 00                	push   $0x0
c01000c3:	e8 ac 0c 00 00       	call   c0100d74 <mon_backtrace>
c01000c8:	83 c4 10             	add    $0x10,%esp
}
c01000cb:	90                   	nop
c01000cc:	c9                   	leave  
c01000cd:	c3                   	ret    

c01000ce <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ce:	55                   	push   %ebp
c01000cf:	89 e5                	mov    %esp,%ebp
c01000d1:	53                   	push   %ebx
c01000d2:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d5:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000db:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000de:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e1:	51                   	push   %ecx
c01000e2:	52                   	push   %edx
c01000e3:	53                   	push   %ebx
c01000e4:	50                   	push   %eax
c01000e5:	e8 ca ff ff ff       	call   c01000b4 <grade_backtrace2>
c01000ea:	83 c4 10             	add    $0x10,%esp
}
c01000ed:	90                   	nop
c01000ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f1:	c9                   	leave  
c01000f2:	c3                   	ret    

c01000f3 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f3:	55                   	push   %ebp
c01000f4:	89 e5                	mov    %esp,%ebp
c01000f6:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000f9:	83 ec 08             	sub    $0x8,%esp
c01000fc:	ff 75 10             	pushl  0x10(%ebp)
c01000ff:	ff 75 08             	pushl  0x8(%ebp)
c0100102:	e8 c7 ff ff ff       	call   c01000ce <grade_backtrace1>
c0100107:	83 c4 10             	add    $0x10,%esp
}
c010010a:	90                   	nop
c010010b:	c9                   	leave  
c010010c:	c3                   	ret    

c010010d <grade_backtrace>:

void
grade_backtrace(void) {
c010010d:	55                   	push   %ebp
c010010e:	89 e5                	mov    %esp,%ebp
c0100110:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100113:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100118:	83 ec 04             	sub    $0x4,%esp
c010011b:	68 00 00 ff ff       	push   $0xffff0000
c0100120:	50                   	push   %eax
c0100121:	6a 00                	push   $0x0
c0100123:	e8 cb ff ff ff       	call   c01000f3 <grade_backtrace0>
c0100128:	83 c4 10             	add    $0x10,%esp
}
c010012b:	90                   	nop
c010012c:	c9                   	leave  
c010012d:	c3                   	ret    

c010012e <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010012e:	55                   	push   %ebp
c010012f:	89 e5                	mov    %esp,%ebp
c0100131:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100134:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100137:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010013a:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010013d:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100140:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100144:	0f b7 c0             	movzwl %ax,%eax
c0100147:	83 e0 03             	and    $0x3,%eax
c010014a:	89 c2                	mov    %eax,%edx
c010014c:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c0100151:	83 ec 04             	sub    $0x4,%esp
c0100154:	52                   	push   %edx
c0100155:	50                   	push   %eax
c0100156:	68 a1 b4 10 c0       	push   $0xc010b4a1
c010015b:	e8 e8 01 00 00       	call   c0100348 <cprintf>
c0100160:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c0100163:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100167:	0f b7 d0             	movzwl %ax,%edx
c010016a:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c010016f:	83 ec 04             	sub    $0x4,%esp
c0100172:	52                   	push   %edx
c0100173:	50                   	push   %eax
c0100174:	68 af b4 10 c0       	push   $0xc010b4af
c0100179:	e8 ca 01 00 00       	call   c0100348 <cprintf>
c010017e:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c0100181:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100185:	0f b7 d0             	movzwl %ax,%edx
c0100188:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c010018d:	83 ec 04             	sub    $0x4,%esp
c0100190:	52                   	push   %edx
c0100191:	50                   	push   %eax
c0100192:	68 bd b4 10 c0       	push   $0xc010b4bd
c0100197:	e8 ac 01 00 00       	call   c0100348 <cprintf>
c010019c:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c010019f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001a3:	0f b7 d0             	movzwl %ax,%edx
c01001a6:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c01001ab:	83 ec 04             	sub    $0x4,%esp
c01001ae:	52                   	push   %edx
c01001af:	50                   	push   %eax
c01001b0:	68 cb b4 10 c0       	push   $0xc010b4cb
c01001b5:	e8 8e 01 00 00       	call   c0100348 <cprintf>
c01001ba:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001bd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001c1:	0f b7 d0             	movzwl %ax,%edx
c01001c4:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c01001c9:	83 ec 04             	sub    $0x4,%esp
c01001cc:	52                   	push   %edx
c01001cd:	50                   	push   %eax
c01001ce:	68 d9 b4 10 c0       	push   $0xc010b4d9
c01001d3:	e8 70 01 00 00       	call   c0100348 <cprintf>
c01001d8:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001db:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c01001e0:	83 c0 01             	add    $0x1,%eax
c01001e3:	a3 00 30 1a c0       	mov    %eax,0xc01a3000
}
c01001e8:	90                   	nop
c01001e9:	c9                   	leave  
c01001ea:	c3                   	ret    

c01001eb <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001eb:	55                   	push   %ebp
c01001ec:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ee:	90                   	nop
c01001ef:	5d                   	pop    %ebp
c01001f0:	c3                   	ret    

c01001f1 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001f1:	55                   	push   %ebp
c01001f2:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001f4:	90                   	nop
c01001f5:	5d                   	pop    %ebp
c01001f6:	c3                   	ret    

c01001f7 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001f7:	55                   	push   %ebp
c01001f8:	89 e5                	mov    %esp,%ebp
c01001fa:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c01001fd:	e8 2c ff ff ff       	call   c010012e <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100202:	83 ec 0c             	sub    $0xc,%esp
c0100205:	68 e8 b4 10 c0       	push   $0xc010b4e8
c010020a:	e8 39 01 00 00       	call   c0100348 <cprintf>
c010020f:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c0100212:	e8 d4 ff ff ff       	call   c01001eb <lab1_switch_to_user>
    lab1_print_cur_status();
c0100217:	e8 12 ff ff ff       	call   c010012e <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010021c:	83 ec 0c             	sub    $0xc,%esp
c010021f:	68 08 b5 10 c0       	push   $0xc010b508
c0100224:	e8 1f 01 00 00       	call   c0100348 <cprintf>
c0100229:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c010022c:	e8 c0 ff ff ff       	call   c01001f1 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100231:	e8 f8 fe ff ff       	call   c010012e <lab1_print_cur_status>
}
c0100236:	90                   	nop
c0100237:	c9                   	leave  
c0100238:	c3                   	ret    

c0100239 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100239:	55                   	push   %ebp
c010023a:	89 e5                	mov    %esp,%ebp
c010023c:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c010023f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100243:	74 13                	je     c0100258 <readline+0x1f>
        cprintf("%s", prompt);
c0100245:	83 ec 08             	sub    $0x8,%esp
c0100248:	ff 75 08             	pushl  0x8(%ebp)
c010024b:	68 27 b5 10 c0       	push   $0xc010b527
c0100250:	e8 f3 00 00 00       	call   c0100348 <cprintf>
c0100255:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c0100258:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010025f:	e8 6f 01 00 00       	call   c01003d3 <getchar>
c0100264:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100267:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010026b:	79 0a                	jns    c0100277 <readline+0x3e>
            return NULL;
c010026d:	b8 00 00 00 00       	mov    $0x0,%eax
c0100272:	e9 82 00 00 00       	jmp    c01002f9 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100277:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010027b:	7e 2b                	jle    c01002a8 <readline+0x6f>
c010027d:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100284:	7f 22                	jg     c01002a8 <readline+0x6f>
            cputchar(c);
c0100286:	83 ec 0c             	sub    $0xc,%esp
c0100289:	ff 75 f0             	pushl  -0x10(%ebp)
c010028c:	e8 dd 00 00 00       	call   c010036e <cputchar>
c0100291:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100297:	8d 50 01             	lea    0x1(%eax),%edx
c010029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a0:	88 90 20 30 1a c0    	mov    %dl,-0x3fe5cfe0(%eax)
c01002a6:	eb 4c                	jmp    c01002f4 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c01002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002ac:	75 1a                	jne    c01002c8 <readline+0x8f>
c01002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002b2:	7e 14                	jle    c01002c8 <readline+0x8f>
            cputchar(c);
c01002b4:	83 ec 0c             	sub    $0xc,%esp
c01002b7:	ff 75 f0             	pushl  -0x10(%ebp)
c01002ba:	e8 af 00 00 00       	call   c010036e <cputchar>
c01002bf:	83 c4 10             	add    $0x10,%esp
            i --;
c01002c2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002c6:	eb 2c                	jmp    c01002f4 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c01002c8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002cc:	74 06                	je     c01002d4 <readline+0x9b>
c01002ce:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002d2:	75 8b                	jne    c010025f <readline+0x26>
            cputchar(c);
c01002d4:	83 ec 0c             	sub    $0xc,%esp
c01002d7:	ff 75 f0             	pushl  -0x10(%ebp)
c01002da:	e8 8f 00 00 00       	call   c010036e <cputchar>
c01002df:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01002e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e5:	05 20 30 1a c0       	add    $0xc01a3020,%eax
c01002ea:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002ed:	b8 20 30 1a c0       	mov    $0xc01a3020,%eax
c01002f2:	eb 05                	jmp    c01002f9 <readline+0xc0>
        c = getchar();
c01002f4:	e9 66 ff ff ff       	jmp    c010025f <readline+0x26>
        }
    }
}
c01002f9:	c9                   	leave  
c01002fa:	c3                   	ret    

c01002fb <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002fb:	55                   	push   %ebp
c01002fc:	89 e5                	mov    %esp,%ebp
c01002fe:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c0100301:	83 ec 0c             	sub    $0xc,%esp
c0100304:	ff 75 08             	pushl  0x8(%ebp)
c0100307:	e8 fc 13 00 00       	call   c0101708 <cons_putc>
c010030c:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c010030f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100312:	8b 00                	mov    (%eax),%eax
c0100314:	8d 50 01             	lea    0x1(%eax),%edx
c0100317:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031a:	89 10                	mov    %edx,(%eax)
}
c010031c:	90                   	nop
c010031d:	c9                   	leave  
c010031e:	c3                   	ret    

c010031f <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010031f:	55                   	push   %ebp
c0100320:	89 e5                	mov    %esp,%ebp
c0100322:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c0100325:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032c:	ff 75 0c             	pushl  0xc(%ebp)
c010032f:	ff 75 08             	pushl  0x8(%ebp)
c0100332:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100335:	50                   	push   %eax
c0100336:	68 fb 02 10 c0       	push   $0xc01002fb
c010033b:	e8 3c a7 00 00       	call   c010aa7c <vprintfmt>
c0100340:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100346:	c9                   	leave  
c0100347:	c3                   	ret    

c0100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100348:	55                   	push   %ebp
c0100349:	89 e5                	mov    %esp,%ebp
c010034b:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010034e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100357:	83 ec 08             	sub    $0x8,%esp
c010035a:	50                   	push   %eax
c010035b:	ff 75 08             	pushl  0x8(%ebp)
c010035e:	e8 bc ff ff ff       	call   c010031f <vcprintf>
c0100363:	83 c4 10             	add    $0x10,%esp
c0100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036c:	c9                   	leave  
c010036d:	c3                   	ret    

c010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010036e:	55                   	push   %ebp
c010036f:	89 e5                	mov    %esp,%ebp
c0100371:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c0100374:	83 ec 0c             	sub    $0xc,%esp
c0100377:	ff 75 08             	pushl  0x8(%ebp)
c010037a:	e8 89 13 00 00       	call   c0101708 <cons_putc>
c010037f:	83 c4 10             	add    $0x10,%esp
}
c0100382:	90                   	nop
c0100383:	c9                   	leave  
c0100384:	c3                   	ret    

c0100385 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100385:	55                   	push   %ebp
c0100386:	89 e5                	mov    %esp,%ebp
c0100388:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c010038b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100392:	eb 14                	jmp    c01003a8 <cputs+0x23>
        cputch(c, &cnt);
c0100394:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100398:	83 ec 08             	sub    $0x8,%esp
c010039b:	8d 55 f0             	lea    -0x10(%ebp),%edx
c010039e:	52                   	push   %edx
c010039f:	50                   	push   %eax
c01003a0:	e8 56 ff ff ff       	call   c01002fb <cputch>
c01003a5:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
c01003a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01003ab:	8d 50 01             	lea    0x1(%eax),%edx
c01003ae:	89 55 08             	mov    %edx,0x8(%ebp)
c01003b1:	0f b6 00             	movzbl (%eax),%eax
c01003b4:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003b7:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003bb:	75 d7                	jne    c0100394 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003bd:	83 ec 08             	sub    $0x8,%esp
c01003c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003c3:	50                   	push   %eax
c01003c4:	6a 0a                	push   $0xa
c01003c6:	e8 30 ff ff ff       	call   c01002fb <cputch>
c01003cb:	83 c4 10             	add    $0x10,%esp
    return cnt;
c01003ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003d1:	c9                   	leave  
c01003d2:	c3                   	ret    

c01003d3 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003d3:	55                   	push   %ebp
c01003d4:	89 e5                	mov    %esp,%ebp
c01003d6:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003d9:	90                   	nop
c01003da:	e8 72 13 00 00       	call   c0101751 <cons_getc>
c01003df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003e6:	74 f2                	je     c01003da <getchar+0x7>
        /* do nothing */;
    return c;
c01003e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003eb:	c9                   	leave  
c01003ec:	c3                   	ret    

c01003ed <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003ed:	55                   	push   %ebp
c01003ee:	89 e5                	mov    %esp,%ebp
c01003f0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f6:	8b 00                	mov    (%eax),%eax
c01003f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01003fe:	8b 00                	mov    (%eax),%eax
c0100400:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100403:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010040a:	e9 d2 00 00 00       	jmp    c01004e1 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010040f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100412:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100415:	01 d0                	add    %edx,%eax
c0100417:	89 c2                	mov    %eax,%edx
c0100419:	c1 ea 1f             	shr    $0x1f,%edx
c010041c:	01 d0                	add    %edx,%eax
c010041e:	d1 f8                	sar    %eax
c0100420:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100423:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100426:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100429:	eb 04                	jmp    c010042f <stab_binsearch+0x42>
            m --;
c010042b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c010042f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100432:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100435:	7c 1f                	jl     c0100456 <stab_binsearch+0x69>
c0100437:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010043a:	89 d0                	mov    %edx,%eax
c010043c:	01 c0                	add    %eax,%eax
c010043e:	01 d0                	add    %edx,%eax
c0100440:	c1 e0 02             	shl    $0x2,%eax
c0100443:	89 c2                	mov    %eax,%edx
c0100445:	8b 45 08             	mov    0x8(%ebp),%eax
c0100448:	01 d0                	add    %edx,%eax
c010044a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010044e:	0f b6 c0             	movzbl %al,%eax
c0100451:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100454:	75 d5                	jne    c010042b <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100456:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100459:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010045c:	7d 0b                	jge    c0100469 <stab_binsearch+0x7c>
            l = true_m + 1;
c010045e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100461:	83 c0 01             	add    $0x1,%eax
c0100464:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100467:	eb 78                	jmp    c01004e1 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100469:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100470:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100473:	89 d0                	mov    %edx,%eax
c0100475:	01 c0                	add    %eax,%eax
c0100477:	01 d0                	add    %edx,%eax
c0100479:	c1 e0 02             	shl    $0x2,%eax
c010047c:	89 c2                	mov    %eax,%edx
c010047e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100481:	01 d0                	add    %edx,%eax
c0100483:	8b 40 08             	mov    0x8(%eax),%eax
c0100486:	39 45 18             	cmp    %eax,0x18(%ebp)
c0100489:	76 13                	jbe    c010049e <stab_binsearch+0xb1>
            *region_left = m;
c010048b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100491:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100493:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100496:	83 c0 01             	add    $0x1,%eax
c0100499:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010049c:	eb 43                	jmp    c01004e1 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010049e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a1:	89 d0                	mov    %edx,%eax
c01004a3:	01 c0                	add    %eax,%eax
c01004a5:	01 d0                	add    %edx,%eax
c01004a7:	c1 e0 02             	shl    $0x2,%eax
c01004aa:	89 c2                	mov    %eax,%edx
c01004ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01004af:	01 d0                	add    %edx,%eax
c01004b1:	8b 40 08             	mov    0x8(%eax),%eax
c01004b4:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004b7:	73 16                	jae    c01004cf <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004bc:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c2:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c7:	83 e8 01             	sub    $0x1,%eax
c01004ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004cd:	eb 12                	jmp    c01004e1 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d5:	89 10                	mov    %edx,(%eax)
            l = m;
c01004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004da:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004dd:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c01004e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004e7:	0f 8e 22 ff ff ff    	jle    c010040f <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01004ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004f1:	75 0f                	jne    c0100502 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f6:	8b 00                	mov    (%eax),%eax
c01004f8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004fe:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0100500:	eb 3f                	jmp    c0100541 <stab_binsearch+0x154>
        l = *region_right;
c0100502:	8b 45 10             	mov    0x10(%ebp),%eax
c0100505:	8b 00                	mov    (%eax),%eax
c0100507:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c010050a:	eb 04                	jmp    c0100510 <stab_binsearch+0x123>
c010050c:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100510:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100513:	8b 00                	mov    (%eax),%eax
c0100515:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100518:	7e 1f                	jle    c0100539 <stab_binsearch+0x14c>
c010051a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010051d:	89 d0                	mov    %edx,%eax
c010051f:	01 c0                	add    %eax,%eax
c0100521:	01 d0                	add    %edx,%eax
c0100523:	c1 e0 02             	shl    $0x2,%eax
c0100526:	89 c2                	mov    %eax,%edx
c0100528:	8b 45 08             	mov    0x8(%ebp),%eax
c010052b:	01 d0                	add    %edx,%eax
c010052d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100531:	0f b6 c0             	movzbl %al,%eax
c0100534:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100537:	75 d3                	jne    c010050c <stab_binsearch+0x11f>
        *region_left = l;
c0100539:	8b 45 0c             	mov    0xc(%ebp),%eax
c010053c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053f:	89 10                	mov    %edx,(%eax)
}
c0100541:	90                   	nop
c0100542:	c9                   	leave  
c0100543:	c3                   	ret    

c0100544 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100544:	55                   	push   %ebp
c0100545:	89 e5                	mov    %esp,%ebp
c0100547:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010054a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010054d:	c7 00 2c b5 10 c0    	movl   $0xc010b52c,(%eax)
    info->eip_line = 0;
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010055d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100560:	c7 40 08 2c b5 10 c0 	movl   $0xc010b52c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100567:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056a:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100571:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100574:	8b 55 08             	mov    0x8(%ebp),%edx
c0100577:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010057a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c0100584:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c010058b:	76 21                	jbe    c01005ae <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c010058d:	c7 45 f4 40 dd 10 c0 	movl   $0xc010dd40,-0xc(%ebp)
        stab_end = __STAB_END__;
c0100594:	c7 45 f0 f8 47 12 c0 	movl   $0xc01247f8,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c010059b:	c7 45 ec f9 47 12 c0 	movl   $0xc01247f9,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005a2:	c7 45 e8 dc c3 12 c0 	movl   $0xc012c3dc,-0x18(%ebp)
c01005a9:	e9 c1 00 00 00       	jmp    c010066f <debuginfo_eip+0x12b>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005ae:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005b5:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01005ba:	85 c0                	test   %eax,%eax
c01005bc:	74 11                	je     c01005cf <debuginfo_eip+0x8b>
c01005be:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01005c3:	8b 40 18             	mov    0x18(%eax),%eax
c01005c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005cd:	75 0a                	jne    c01005d9 <debuginfo_eip+0x95>
            return -1;
c01005cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005d4:	e9 40 03 00 00       	jmp    c0100919 <debuginfo_eip+0x3d5>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01005d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005dc:	6a 00                	push   $0x0
c01005de:	6a 10                	push   $0x10
c01005e0:	50                   	push   %eax
c01005e1:	ff 75 e0             	pushl  -0x20(%ebp)
c01005e4:	e8 8a 82 00 00       	call   c0108873 <user_mem_check>
c01005e9:	83 c4 10             	add    $0x10,%esp
c01005ec:	85 c0                	test   %eax,%eax
c01005ee:	75 0a                	jne    c01005fa <debuginfo_eip+0xb6>
            return -1;
c01005f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005f5:	e9 1f 03 00 00       	jmp    c0100919 <debuginfo_eip+0x3d5>
        }

        stabs = usd->stabs;
c01005fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005fd:	8b 00                	mov    (%eax),%eax
c01005ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c0100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100605:	8b 40 04             	mov    0x4(%eax),%eax
c0100608:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c010060b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010060e:	8b 40 08             	mov    0x8(%eax),%eax
c0100611:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100617:	8b 40 0c             	mov    0xc(%eax),%eax
c010061a:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c010061d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100620:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100623:	29 c8                	sub    %ecx,%eax
c0100625:	89 c2                	mov    %eax,%edx
c0100627:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010062a:	6a 00                	push   $0x0
c010062c:	52                   	push   %edx
c010062d:	50                   	push   %eax
c010062e:	ff 75 e0             	pushl  -0x20(%ebp)
c0100631:	e8 3d 82 00 00       	call   c0108873 <user_mem_check>
c0100636:	83 c4 10             	add    $0x10,%esp
c0100639:	85 c0                	test   %eax,%eax
c010063b:	75 0a                	jne    c0100647 <debuginfo_eip+0x103>
            return -1;
c010063d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100642:	e9 d2 02 00 00       	jmp    c0100919 <debuginfo_eip+0x3d5>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100647:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010064a:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010064d:	89 c2                	mov    %eax,%edx
c010064f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100652:	6a 00                	push   $0x0
c0100654:	52                   	push   %edx
c0100655:	50                   	push   %eax
c0100656:	ff 75 e0             	pushl  -0x20(%ebp)
c0100659:	e8 15 82 00 00       	call   c0108873 <user_mem_check>
c010065e:	83 c4 10             	add    $0x10,%esp
c0100661:	85 c0                	test   %eax,%eax
c0100663:	75 0a                	jne    c010066f <debuginfo_eip+0x12b>
            return -1;
c0100665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010066a:	e9 aa 02 00 00       	jmp    c0100919 <debuginfo_eip+0x3d5>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010066f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100672:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100675:	76 0d                	jbe    c0100684 <debuginfo_eip+0x140>
c0100677:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067a:	83 e8 01             	sub    $0x1,%eax
c010067d:	0f b6 00             	movzbl (%eax),%eax
c0100680:	84 c0                	test   %al,%al
c0100682:	74 0a                	je     c010068e <debuginfo_eip+0x14a>
        return -1;
c0100684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100689:	e9 8b 02 00 00       	jmp    c0100919 <debuginfo_eip+0x3d5>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0100695:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100698:	2b 45 f4             	sub    -0xc(%ebp),%eax
c010069b:	c1 f8 02             	sar    $0x2,%eax
c010069e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a4:	83 e8 01             	sub    $0x1,%eax
c01006a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006aa:	83 ec 0c             	sub    $0xc,%esp
c01006ad:	ff 75 08             	pushl  0x8(%ebp)
c01006b0:	6a 64                	push   $0x64
c01006b2:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006b5:	50                   	push   %eax
c01006b6:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006b9:	50                   	push   %eax
c01006ba:	ff 75 f4             	pushl  -0xc(%ebp)
c01006bd:	e8 2b fd ff ff       	call   c01003ed <stab_binsearch>
c01006c2:	83 c4 20             	add    $0x20,%esp
    if (lfile == 0)
c01006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c8:	85 c0                	test   %eax,%eax
c01006ca:	75 0a                	jne    c01006d6 <debuginfo_eip+0x192>
        return -1;
c01006cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d1:	e9 43 02 00 00       	jmp    c0100919 <debuginfo_eip+0x3d5>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01006dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e2:	83 ec 0c             	sub    $0xc,%esp
c01006e5:	ff 75 08             	pushl  0x8(%ebp)
c01006e8:	6a 24                	push   $0x24
c01006ea:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01006ed:	50                   	push   %eax
c01006ee:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01006f1:	50                   	push   %eax
c01006f2:	ff 75 f4             	pushl  -0xc(%ebp)
c01006f5:	e8 f3 fc ff ff       	call   c01003ed <stab_binsearch>
c01006fa:	83 c4 20             	add    $0x20,%esp

    if (lfun <= rfun) {
c01006fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100700:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100703:	39 c2                	cmp    %eax,%edx
c0100705:	7f 78                	jg     c010077f <debuginfo_eip+0x23b>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100707:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010070a:	89 c2                	mov    %eax,%edx
c010070c:	89 d0                	mov    %edx,%eax
c010070e:	01 c0                	add    %eax,%eax
c0100710:	01 d0                	add    %edx,%eax
c0100712:	c1 e0 02             	shl    $0x2,%eax
c0100715:	89 c2                	mov    %eax,%edx
c0100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010071a:	01 d0                	add    %edx,%eax
c010071c:	8b 10                	mov    (%eax),%edx
c010071e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100721:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100724:	39 c2                	cmp    %eax,%edx
c0100726:	73 22                	jae    c010074a <debuginfo_eip+0x206>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100728:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010072b:	89 c2                	mov    %eax,%edx
c010072d:	89 d0                	mov    %edx,%eax
c010072f:	01 c0                	add    %eax,%eax
c0100731:	01 d0                	add    %edx,%eax
c0100733:	c1 e0 02             	shl    $0x2,%eax
c0100736:	89 c2                	mov    %eax,%edx
c0100738:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073b:	01 d0                	add    %edx,%eax
c010073d:	8b 10                	mov    (%eax),%edx
c010073f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100742:	01 c2                	add    %eax,%edx
c0100744:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100747:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010074a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010074d:	89 c2                	mov    %eax,%edx
c010074f:	89 d0                	mov    %edx,%eax
c0100751:	01 c0                	add    %eax,%eax
c0100753:	01 d0                	add    %edx,%eax
c0100755:	c1 e0 02             	shl    $0x2,%eax
c0100758:	89 c2                	mov    %eax,%edx
c010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075d:	01 d0                	add    %edx,%eax
c010075f:	8b 50 08             	mov    0x8(%eax),%edx
c0100762:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100765:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100768:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076b:	8b 40 10             	mov    0x10(%eax),%eax
c010076e:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100771:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100774:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c0100777:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010077a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010077d:	eb 15                	jmp    c0100794 <debuginfo_eip+0x250>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010077f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100782:	8b 55 08             	mov    0x8(%ebp),%edx
c0100785:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100788:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010078b:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c010078e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100791:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100794:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100797:	8b 40 08             	mov    0x8(%eax),%eax
c010079a:	83 ec 08             	sub    $0x8,%esp
c010079d:	6a 3a                	push   $0x3a
c010079f:	50                   	push   %eax
c01007a0:	e8 b3 a9 00 00       	call   c010b158 <strfind>
c01007a5:	83 c4 10             	add    $0x10,%esp
c01007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01007ab:	8b 4a 08             	mov    0x8(%edx),%ecx
c01007ae:	29 c8                	sub    %ecx,%eax
c01007b0:	89 c2                	mov    %eax,%edx
c01007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b5:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007b8:	83 ec 0c             	sub    $0xc,%esp
c01007bb:	ff 75 08             	pushl  0x8(%ebp)
c01007be:	6a 44                	push   $0x44
c01007c0:	8d 45 c8             	lea    -0x38(%ebp),%eax
c01007c3:	50                   	push   %eax
c01007c4:	8d 45 cc             	lea    -0x34(%ebp),%eax
c01007c7:	50                   	push   %eax
c01007c8:	ff 75 f4             	pushl  -0xc(%ebp)
c01007cb:	e8 1d fc ff ff       	call   c01003ed <stab_binsearch>
c01007d0:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c01007d3:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01007d6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01007d9:	39 c2                	cmp    %eax,%edx
c01007db:	7f 24                	jg     c0100801 <debuginfo_eip+0x2bd>
        info->eip_line = stabs[rline].n_desc;
c01007dd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01007e0:	89 c2                	mov    %eax,%edx
c01007e2:	89 d0                	mov    %edx,%eax
c01007e4:	01 c0                	add    %eax,%eax
c01007e6:	01 d0                	add    %edx,%eax
c01007e8:	c1 e0 02             	shl    $0x2,%eax
c01007eb:	89 c2                	mov    %eax,%edx
c01007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f0:	01 d0                	add    %edx,%eax
c01007f2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01007f6:	0f b7 d0             	movzwl %ax,%edx
c01007f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007fc:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01007ff:	eb 13                	jmp    c0100814 <debuginfo_eip+0x2d0>
        return -1;
c0100801:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100806:	e9 0e 01 00 00       	jmp    c0100919 <debuginfo_eip+0x3d5>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010080b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010080e:	83 e8 01             	sub    $0x1,%eax
c0100811:	89 45 cc             	mov    %eax,-0x34(%ebp)
    while (lline >= lfile
c0100814:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100817:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010081a:	39 c2                	cmp    %eax,%edx
c010081c:	7c 56                	jl     c0100874 <debuginfo_eip+0x330>
           && stabs[lline].n_type != N_SOL
c010081e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100821:	89 c2                	mov    %eax,%edx
c0100823:	89 d0                	mov    %edx,%eax
c0100825:	01 c0                	add    %eax,%eax
c0100827:	01 d0                	add    %edx,%eax
c0100829:	c1 e0 02             	shl    $0x2,%eax
c010082c:	89 c2                	mov    %eax,%edx
c010082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100831:	01 d0                	add    %edx,%eax
c0100833:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100837:	3c 84                	cmp    $0x84,%al
c0100839:	74 39                	je     c0100874 <debuginfo_eip+0x330>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010083b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010083e:	89 c2                	mov    %eax,%edx
c0100840:	89 d0                	mov    %edx,%eax
c0100842:	01 c0                	add    %eax,%eax
c0100844:	01 d0                	add    %edx,%eax
c0100846:	c1 e0 02             	shl    $0x2,%eax
c0100849:	89 c2                	mov    %eax,%edx
c010084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010084e:	01 d0                	add    %edx,%eax
c0100850:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100854:	3c 64                	cmp    $0x64,%al
c0100856:	75 b3                	jne    c010080b <debuginfo_eip+0x2c7>
c0100858:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	8b 40 08             	mov    0x8(%eax),%eax
c0100870:	85 c0                	test   %eax,%eax
c0100872:	74 97                	je     c010080b <debuginfo_eip+0x2c7>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100874:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100877:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010087a:	39 c2                	cmp    %eax,%edx
c010087c:	7c 42                	jl     c01008c0 <debuginfo_eip+0x37c>
c010087e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100881:	89 c2                	mov    %eax,%edx
c0100883:	89 d0                	mov    %edx,%eax
c0100885:	01 c0                	add    %eax,%eax
c0100887:	01 d0                	add    %edx,%eax
c0100889:	c1 e0 02             	shl    $0x2,%eax
c010088c:	89 c2                	mov    %eax,%edx
c010088e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100891:	01 d0                	add    %edx,%eax
c0100893:	8b 10                	mov    (%eax),%edx
c0100895:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100898:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010089b:	39 c2                	cmp    %eax,%edx
c010089d:	73 21                	jae    c01008c0 <debuginfo_eip+0x37c>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010089f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008a2:	89 c2                	mov    %eax,%edx
c01008a4:	89 d0                	mov    %edx,%eax
c01008a6:	01 c0                	add    %eax,%eax
c01008a8:	01 d0                	add    %edx,%eax
c01008aa:	c1 e0 02             	shl    $0x2,%eax
c01008ad:	89 c2                	mov    %eax,%edx
c01008af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008b2:	01 d0                	add    %edx,%eax
c01008b4:	8b 10                	mov    (%eax),%edx
c01008b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008b9:	01 c2                	add    %eax,%edx
c01008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008be:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01008c6:	39 c2                	cmp    %eax,%edx
c01008c8:	7d 4a                	jge    c0100914 <debuginfo_eip+0x3d0>
        for (lline = lfun + 1;
c01008ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008cd:	83 c0 01             	add    $0x1,%eax
c01008d0:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01008d3:	eb 18                	jmp    c01008ed <debuginfo_eip+0x3a9>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008d8:	8b 40 14             	mov    0x14(%eax),%eax
c01008db:	8d 50 01             	lea    0x1(%eax),%edx
c01008de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e1:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c01008e4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008e7:	83 c0 01             	add    $0x1,%eax
c01008ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008ed:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
        for (lline = lfun + 1;
c01008f3:	39 c2                	cmp    %eax,%edx
c01008f5:	7d 1d                	jge    c0100914 <debuginfo_eip+0x3d0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01008f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008fa:	89 c2                	mov    %eax,%edx
c01008fc:	89 d0                	mov    %edx,%eax
c01008fe:	01 c0                	add    %eax,%eax
c0100900:	01 d0                	add    %edx,%eax
c0100902:	c1 e0 02             	shl    $0x2,%eax
c0100905:	89 c2                	mov    %eax,%edx
c0100907:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010090a:	01 d0                	add    %edx,%eax
c010090c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100910:	3c a0                	cmp    $0xa0,%al
c0100912:	74 c1                	je     c01008d5 <debuginfo_eip+0x391>
        }
    }
    return 0;
c0100914:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100919:	c9                   	leave  
c010091a:	c3                   	ret    

c010091b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010091b:	55                   	push   %ebp
c010091c:	89 e5                	mov    %esp,%ebp
c010091e:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100921:	83 ec 0c             	sub    $0xc,%esp
c0100924:	68 36 b5 10 c0       	push   $0xc010b536
c0100929:	e8 1a fa ff ff       	call   c0100348 <cprintf>
c010092e:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100931:	83 ec 08             	sub    $0x8,%esp
c0100934:	68 36 00 10 c0       	push   $0xc0100036
c0100939:	68 4f b5 10 c0       	push   $0xc010b54f
c010093e:	e8 05 fa ff ff       	call   c0100348 <cprintf>
c0100943:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100946:	83 ec 08             	sub    $0x8,%esp
c0100949:	68 6c b4 10 c0       	push   $0xc010b46c
c010094e:	68 67 b5 10 c0       	push   $0xc010b567
c0100953:	e8 f0 f9 ff ff       	call   c0100348 <cprintf>
c0100958:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c010095b:	83 ec 08             	sub    $0x8,%esp
c010095e:	68 00 30 1a c0       	push   $0xc01a3000
c0100963:	68 7f b5 10 c0       	push   $0xc010b57f
c0100968:	e8 db f9 ff ff       	call   c0100348 <cprintf>
c010096d:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0100970:	83 ec 08             	sub    $0x8,%esp
c0100973:	68 54 61 1a c0       	push   $0xc01a6154
c0100978:	68 97 b5 10 c0       	push   $0xc010b597
c010097d:	e8 c6 f9 ff ff       	call   c0100348 <cprintf>
c0100982:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100985:	b8 54 61 1a c0       	mov    $0xc01a6154,%eax
c010098a:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c010098f:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100994:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c010099a:	85 c0                	test   %eax,%eax
c010099c:	0f 48 c2             	cmovs  %edx,%eax
c010099f:	c1 f8 0a             	sar    $0xa,%eax
c01009a2:	83 ec 08             	sub    $0x8,%esp
c01009a5:	50                   	push   %eax
c01009a6:	68 b0 b5 10 c0       	push   $0xc010b5b0
c01009ab:	e8 98 f9 ff ff       	call   c0100348 <cprintf>
c01009b0:	83 c4 10             	add    $0x10,%esp
}
c01009b3:	90                   	nop
c01009b4:	c9                   	leave  
c01009b5:	c3                   	ret    

c01009b6 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009b6:	55                   	push   %ebp
c01009b7:	89 e5                	mov    %esp,%ebp
c01009b9:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009bf:	83 ec 08             	sub    $0x8,%esp
c01009c2:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009c5:	50                   	push   %eax
c01009c6:	ff 75 08             	pushl  0x8(%ebp)
c01009c9:	e8 76 fb ff ff       	call   c0100544 <debuginfo_eip>
c01009ce:	83 c4 10             	add    $0x10,%esp
c01009d1:	85 c0                	test   %eax,%eax
c01009d3:	74 15                	je     c01009ea <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009d5:	83 ec 08             	sub    $0x8,%esp
c01009d8:	ff 75 08             	pushl  0x8(%ebp)
c01009db:	68 da b5 10 c0       	push   $0xc010b5da
c01009e0:	e8 63 f9 ff ff       	call   c0100348 <cprintf>
c01009e5:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c01009e8:	eb 65                	jmp    c0100a4f <print_debuginfo+0x99>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01009ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01009f1:	eb 1c                	jmp    c0100a0f <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01009f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01009f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f9:	01 d0                	add    %edx,%eax
c01009fb:	0f b6 00             	movzbl (%eax),%eax
c01009fe:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a04:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a07:	01 ca                	add    %ecx,%edx
c0100a09:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a0b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a12:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a15:	7c dc                	jl     c01009f3 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a17:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a20:	01 d0                	add    %edx,%eax
c0100a22:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a25:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a28:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a2b:	29 d0                	sub    %edx,%eax
c0100a2d:	89 c1                	mov    %eax,%ecx
c0100a2f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a32:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a35:	83 ec 0c             	sub    $0xc,%esp
c0100a38:	51                   	push   %ecx
c0100a39:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a3f:	51                   	push   %ecx
c0100a40:	52                   	push   %edx
c0100a41:	50                   	push   %eax
c0100a42:	68 f6 b5 10 c0       	push   $0xc010b5f6
c0100a47:	e8 fc f8 ff ff       	call   c0100348 <cprintf>
c0100a4c:	83 c4 20             	add    $0x20,%esp
}
c0100a4f:	90                   	nop
c0100a50:	c9                   	leave  
c0100a51:	c3                   	ret    

c0100a52 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a52:	55                   	push   %ebp
c0100a53:	89 e5                	mov    %esp,%ebp
c0100a55:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a58:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a5b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a61:	c9                   	leave  
c0100a62:	c3                   	ret    

c0100a63 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a63:	55                   	push   %ebp
c0100a64:	89 e5                	mov    %esp,%ebp
c0100a66:	83 ec 28             	sub    $0x28,%esp
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t eip, ebp;
    eip = read_eip();
c0100a69:	e8 e4 ff ff ff       	call   c0100a52 <read_eip>
c0100a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a71:	89 e8                	mov    %ebp,%eax
c0100a73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100a76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    ebp = read_ebp();
c0100a79:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100a7c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a83:	e9 87 00 00 00       	jmp    c0100b0f <print_stackframe+0xac>
    {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100a88:	83 ec 04             	sub    $0x4,%esp
c0100a8b:	ff 75 f4             	pushl  -0xc(%ebp)
c0100a8e:	ff 75 f0             	pushl  -0x10(%ebp)
c0100a91:	68 08 b6 10 c0       	push   $0xc010b608
c0100a96:	e8 ad f8 ff ff       	call   c0100348 <cprintf>
c0100a9b:	83 c4 10             	add    $0x10,%esp
        for (j = 0; j < 4; j++)
c0100a9e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100aa5:	eb 29                	jmp    c0100ad0 <print_stackframe+0x6d>
        {
            cprintf("0x%08x ", ((uint32_t *)ebp + 2)[j]);
c0100aa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aaa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ab4:	01 d0                	add    %edx,%eax
c0100ab6:	83 c0 08             	add    $0x8,%eax
c0100ab9:	8b 00                	mov    (%eax),%eax
c0100abb:	83 ec 08             	sub    $0x8,%esp
c0100abe:	50                   	push   %eax
c0100abf:	68 24 b6 10 c0       	push   $0xc010b624
c0100ac4:	e8 7f f8 ff ff       	call   c0100348 <cprintf>
c0100ac9:	83 c4 10             	add    $0x10,%esp
        for (j = 0; j < 4; j++)
c0100acc:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100ad0:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100ad4:	7e d1                	jle    c0100aa7 <print_stackframe+0x44>
        }
        cprintf("\n");
c0100ad6:	83 ec 0c             	sub    $0xc,%esp
c0100ad9:	68 2c b6 10 c0       	push   $0xc010b62c
c0100ade:	e8 65 f8 ff ff       	call   c0100348 <cprintf>
c0100ae3:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0100ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae9:	83 e8 01             	sub    $0x1,%eax
c0100aec:	83 ec 0c             	sub    $0xc,%esp
c0100aef:	50                   	push   %eax
c0100af0:	e8 c1 fe ff ff       	call   c01009b6 <print_debuginfo>
c0100af5:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c0100af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100afb:	83 c0 04             	add    $0x4,%eax
c0100afe:	8b 00                	mov    (%eax),%eax
c0100b00:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b06:	8b 00                	mov    (%eax),%eax
c0100b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100b0b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100b0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b13:	74 0a                	je     c0100b1f <print_stackframe+0xbc>
c0100b15:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b19:	0f 8e 69 ff ff ff    	jle    c0100a88 <print_stackframe+0x25>
    }
	cprintf("What the fuck?");
c0100b1f:	83 ec 0c             	sub    $0xc,%esp
c0100b22:	68 2e b6 10 c0       	push   $0xc010b62e
c0100b27:	e8 1c f8 ff ff       	call   c0100348 <cprintf>
c0100b2c:	83 c4 10             	add    $0x10,%esp
}
c0100b2f:	90                   	nop
c0100b30:	c9                   	leave  
c0100b31:	c3                   	ret    

c0100b32 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b32:	55                   	push   %ebp
c0100b33:	89 e5                	mov    %esp,%ebp
c0100b35:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0100b38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b3f:	eb 0c                	jmp    c0100b4d <parse+0x1b>
            *buf ++ = '\0';
c0100b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b44:	8d 50 01             	lea    0x1(%eax),%edx
c0100b47:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b4a:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b50:	0f b6 00             	movzbl (%eax),%eax
c0100b53:	84 c0                	test   %al,%al
c0100b55:	74 1e                	je     c0100b75 <parse+0x43>
c0100b57:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5a:	0f b6 00             	movzbl (%eax),%eax
c0100b5d:	0f be c0             	movsbl %al,%eax
c0100b60:	83 ec 08             	sub    $0x8,%esp
c0100b63:	50                   	push   %eax
c0100b64:	68 c0 b6 10 c0       	push   $0xc010b6c0
c0100b69:	e8 b7 a5 00 00       	call   c010b125 <strchr>
c0100b6e:	83 c4 10             	add    $0x10,%esp
c0100b71:	85 c0                	test   %eax,%eax
c0100b73:	75 cc                	jne    c0100b41 <parse+0xf>
        }
        if (*buf == '\0') {
c0100b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b78:	0f b6 00             	movzbl (%eax),%eax
c0100b7b:	84 c0                	test   %al,%al
c0100b7d:	74 65                	je     c0100be4 <parse+0xb2>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b7f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b83:	75 12                	jne    c0100b97 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b85:	83 ec 08             	sub    $0x8,%esp
c0100b88:	6a 10                	push   $0x10
c0100b8a:	68 c5 b6 10 c0       	push   $0xc010b6c5
c0100b8f:	e8 b4 f7 ff ff       	call   c0100348 <cprintf>
c0100b94:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0100b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b9a:	8d 50 01             	lea    0x1(%eax),%edx
c0100b9d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100ba0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100baa:	01 c2                	add    %eax,%edx
c0100bac:	8b 45 08             	mov    0x8(%ebp),%eax
c0100baf:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bb1:	eb 04                	jmp    c0100bb7 <parse+0x85>
            buf ++;
c0100bb3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bba:	0f b6 00             	movzbl (%eax),%eax
c0100bbd:	84 c0                	test   %al,%al
c0100bbf:	74 8c                	je     c0100b4d <parse+0x1b>
c0100bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc4:	0f b6 00             	movzbl (%eax),%eax
c0100bc7:	0f be c0             	movsbl %al,%eax
c0100bca:	83 ec 08             	sub    $0x8,%esp
c0100bcd:	50                   	push   %eax
c0100bce:	68 c0 b6 10 c0       	push   $0xc010b6c0
c0100bd3:	e8 4d a5 00 00       	call   c010b125 <strchr>
c0100bd8:	83 c4 10             	add    $0x10,%esp
c0100bdb:	85 c0                	test   %eax,%eax
c0100bdd:	74 d4                	je     c0100bb3 <parse+0x81>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bdf:	e9 69 ff ff ff       	jmp    c0100b4d <parse+0x1b>
            break;
c0100be4:	90                   	nop
        }
    }
    return argc;
c0100be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100be8:	c9                   	leave  
c0100be9:	c3                   	ret    

c0100bea <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bea:	55                   	push   %ebp
c0100beb:	89 e5                	mov    %esp,%ebp
c0100bed:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100bf0:	83 ec 08             	sub    $0x8,%esp
c0100bf3:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bf6:	50                   	push   %eax
c0100bf7:	ff 75 08             	pushl  0x8(%ebp)
c0100bfa:	e8 33 ff ff ff       	call   c0100b32 <parse>
c0100bff:	83 c4 10             	add    $0x10,%esp
c0100c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c09:	75 0a                	jne    c0100c15 <runcmd+0x2b>
        return 0;
c0100c0b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c10:	e9 83 00 00 00       	jmp    c0100c98 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c1c:	eb 59                	jmp    c0100c77 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c1e:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100c21:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c24:	89 c8                	mov    %ecx,%eax
c0100c26:	01 c0                	add    %eax,%eax
c0100c28:	01 c8                	add    %ecx,%eax
c0100c2a:	c1 e0 02             	shl    $0x2,%eax
c0100c2d:	05 00 f0 12 c0       	add    $0xc012f000,%eax
c0100c32:	8b 00                	mov    (%eax),%eax
c0100c34:	83 ec 08             	sub    $0x8,%esp
c0100c37:	52                   	push   %edx
c0100c38:	50                   	push   %eax
c0100c39:	e8 48 a4 00 00       	call   c010b086 <strcmp>
c0100c3e:	83 c4 10             	add    $0x10,%esp
c0100c41:	85 c0                	test   %eax,%eax
c0100c43:	75 2e                	jne    c0100c73 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c48:	89 d0                	mov    %edx,%eax
c0100c4a:	01 c0                	add    %eax,%eax
c0100c4c:	01 d0                	add    %edx,%eax
c0100c4e:	c1 e0 02             	shl    $0x2,%eax
c0100c51:	05 08 f0 12 c0       	add    $0xc012f008,%eax
c0100c56:	8b 10                	mov    (%eax),%edx
c0100c58:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c5b:	83 c0 04             	add    $0x4,%eax
c0100c5e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c61:	83 e9 01             	sub    $0x1,%ecx
c0100c64:	83 ec 04             	sub    $0x4,%esp
c0100c67:	ff 75 0c             	pushl  0xc(%ebp)
c0100c6a:	50                   	push   %eax
c0100c6b:	51                   	push   %ecx
c0100c6c:	ff d2                	call   *%edx
c0100c6e:	83 c4 10             	add    $0x10,%esp
c0100c71:	eb 25                	jmp    c0100c98 <runcmd+0xae>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c7a:	83 f8 02             	cmp    $0x2,%eax
c0100c7d:	76 9f                	jbe    c0100c1e <runcmd+0x34>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c7f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c82:	83 ec 08             	sub    $0x8,%esp
c0100c85:	50                   	push   %eax
c0100c86:	68 e3 b6 10 c0       	push   $0xc010b6e3
c0100c8b:	e8 b8 f6 ff ff       	call   c0100348 <cprintf>
c0100c90:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c98:	c9                   	leave  
c0100c99:	c3                   	ret    

c0100c9a <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c9a:	55                   	push   %ebp
c0100c9b:	89 e5                	mov    %esp,%ebp
c0100c9d:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100ca0:	83 ec 0c             	sub    $0xc,%esp
c0100ca3:	68 fc b6 10 c0       	push   $0xc010b6fc
c0100ca8:	e8 9b f6 ff ff       	call   c0100348 <cprintf>
c0100cad:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0100cb0:	83 ec 0c             	sub    $0xc,%esp
c0100cb3:	68 24 b7 10 c0       	push   $0xc010b724
c0100cb8:	e8 8b f6 ff ff       	call   c0100348 <cprintf>
c0100cbd:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0100cc0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cc4:	74 0e                	je     c0100cd4 <kmonitor+0x3a>
        print_trapframe(tf);
c0100cc6:	83 ec 0c             	sub    $0xc,%esp
c0100cc9:	ff 75 08             	pushl  0x8(%ebp)
c0100ccc:	e8 e9 16 00 00       	call   c01023ba <print_trapframe>
c0100cd1:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cd4:	83 ec 0c             	sub    $0xc,%esp
c0100cd7:	68 49 b7 10 c0       	push   $0xc010b749
c0100cdc:	e8 58 f5 ff ff       	call   c0100239 <readline>
c0100ce1:	83 c4 10             	add    $0x10,%esp
c0100ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ce7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ceb:	74 e7                	je     c0100cd4 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c0100ced:	83 ec 08             	sub    $0x8,%esp
c0100cf0:	ff 75 08             	pushl  0x8(%ebp)
c0100cf3:	ff 75 f4             	pushl  -0xc(%ebp)
c0100cf6:	e8 ef fe ff ff       	call   c0100bea <runcmd>
c0100cfb:	83 c4 10             	add    $0x10,%esp
c0100cfe:	85 c0                	test   %eax,%eax
c0100d00:	78 02                	js     c0100d04 <kmonitor+0x6a>
        if ((buf = readline("K> ")) != NULL) {
c0100d02:	eb d0                	jmp    c0100cd4 <kmonitor+0x3a>
                break;
c0100d04:	90                   	nop
            }
        }
    }
}
c0100d05:	90                   	nop
c0100d06:	c9                   	leave  
c0100d07:	c3                   	ret    

c0100d08 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d08:	55                   	push   %ebp
c0100d09:	89 e5                	mov    %esp,%ebp
c0100d0b:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d15:	eb 3c                	jmp    c0100d53 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d17:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d1a:	89 d0                	mov    %edx,%eax
c0100d1c:	01 c0                	add    %eax,%eax
c0100d1e:	01 d0                	add    %edx,%eax
c0100d20:	c1 e0 02             	shl    $0x2,%eax
c0100d23:	05 04 f0 12 c0       	add    $0xc012f004,%eax
c0100d28:	8b 10                	mov    (%eax),%edx
c0100d2a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100d2d:	89 c8                	mov    %ecx,%eax
c0100d2f:	01 c0                	add    %eax,%eax
c0100d31:	01 c8                	add    %ecx,%eax
c0100d33:	c1 e0 02             	shl    $0x2,%eax
c0100d36:	05 00 f0 12 c0       	add    $0xc012f000,%eax
c0100d3b:	8b 00                	mov    (%eax),%eax
c0100d3d:	83 ec 04             	sub    $0x4,%esp
c0100d40:	52                   	push   %edx
c0100d41:	50                   	push   %eax
c0100d42:	68 4d b7 10 c0       	push   $0xc010b74d
c0100d47:	e8 fc f5 ff ff       	call   c0100348 <cprintf>
c0100d4c:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d4f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d56:	83 f8 02             	cmp    $0x2,%eax
c0100d59:	76 bc                	jbe    c0100d17 <mon_help+0xf>
    }
    return 0;
c0100d5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d60:	c9                   	leave  
c0100d61:	c3                   	ret    

c0100d62 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d62:	55                   	push   %ebp
c0100d63:	89 e5                	mov    %esp,%ebp
c0100d65:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d68:	e8 ae fb ff ff       	call   c010091b <print_kerninfo>
    return 0;
c0100d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d72:	c9                   	leave  
c0100d73:	c3                   	ret    

c0100d74 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d74:	55                   	push   %ebp
c0100d75:	89 e5                	mov    %esp,%ebp
c0100d77:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d7a:	e8 e4 fc ff ff       	call   c0100a63 <print_stackframe>
    return 0;
c0100d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d84:	c9                   	leave  
c0100d85:	c3                   	ret    

c0100d86 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100d86:	55                   	push   %ebp
c0100d87:	89 e5                	mov    %esp,%ebp
c0100d89:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c0100d8c:	a1 20 34 1a c0       	mov    0xc01a3420,%eax
c0100d91:	85 c0                	test   %eax,%eax
c0100d93:	75 5f                	jne    c0100df4 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0100d95:	c7 05 20 34 1a c0 01 	movl   $0x1,0xc01a3420
c0100d9c:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d9f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100da5:	83 ec 04             	sub    $0x4,%esp
c0100da8:	ff 75 0c             	pushl  0xc(%ebp)
c0100dab:	ff 75 08             	pushl  0x8(%ebp)
c0100dae:	68 56 b7 10 c0       	push   $0xc010b756
c0100db3:	e8 90 f5 ff ff       	call   c0100348 <cprintf>
c0100db8:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0100dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dbe:	83 ec 08             	sub    $0x8,%esp
c0100dc1:	50                   	push   %eax
c0100dc2:	ff 75 10             	pushl  0x10(%ebp)
c0100dc5:	e8 55 f5 ff ff       	call   c010031f <vcprintf>
c0100dca:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100dcd:	83 ec 0c             	sub    $0xc,%esp
c0100dd0:	68 72 b7 10 c0       	push   $0xc010b772
c0100dd5:	e8 6e f5 ff ff       	call   c0100348 <cprintf>
c0100dda:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c0100ddd:	83 ec 0c             	sub    $0xc,%esp
c0100de0:	68 74 b7 10 c0       	push   $0xc010b774
c0100de5:	e8 5e f5 ff ff       	call   c0100348 <cprintf>
c0100dea:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c0100ded:	e8 71 fc ff ff       	call   c0100a63 <print_stackframe>
c0100df2:	eb 01                	jmp    c0100df5 <__panic+0x6f>
        goto panic_dead;
c0100df4:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100df5:	e8 91 11 00 00       	call   c0101f8b <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100dfa:	83 ec 0c             	sub    $0xc,%esp
c0100dfd:	6a 00                	push   $0x0
c0100dff:	e8 96 fe ff ff       	call   c0100c9a <kmonitor>
c0100e04:	83 c4 10             	add    $0x10,%esp
c0100e07:	eb f1                	jmp    c0100dfa <__panic+0x74>

c0100e09 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e09:	55                   	push   %ebp
c0100e0a:	89 e5                	mov    %esp,%ebp
c0100e0c:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e0f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e15:	83 ec 04             	sub    $0x4,%esp
c0100e18:	ff 75 0c             	pushl  0xc(%ebp)
c0100e1b:	ff 75 08             	pushl  0x8(%ebp)
c0100e1e:	68 86 b7 10 c0       	push   $0xc010b786
c0100e23:	e8 20 f5 ff ff       	call   c0100348 <cprintf>
c0100e28:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0100e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e2e:	83 ec 08             	sub    $0x8,%esp
c0100e31:	50                   	push   %eax
c0100e32:	ff 75 10             	pushl  0x10(%ebp)
c0100e35:	e8 e5 f4 ff ff       	call   c010031f <vcprintf>
c0100e3a:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100e3d:	83 ec 0c             	sub    $0xc,%esp
c0100e40:	68 72 b7 10 c0       	push   $0xc010b772
c0100e45:	e8 fe f4 ff ff       	call   c0100348 <cprintf>
c0100e4a:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0100e4d:	90                   	nop
c0100e4e:	c9                   	leave  
c0100e4f:	c3                   	ret    

c0100e50 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100e50:	55                   	push   %ebp
c0100e51:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100e53:	a1 20 34 1a c0       	mov    0xc01a3420,%eax
}
c0100e58:	5d                   	pop    %ebp
c0100e59:	c3                   	ret    

c0100e5a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100e5a:	55                   	push   %ebp
c0100e5b:	89 e5                	mov    %esp,%ebp
c0100e5d:	83 ec 18             	sub    $0x18,%esp
c0100e60:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100e66:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e6a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e6e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e72:	ee                   	out    %al,(%dx)
}
c0100e73:	90                   	nop
c0100e74:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e7a:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e7e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e82:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e86:	ee                   	out    %al,(%dx)
}
c0100e87:	90                   	nop
c0100e88:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e8e:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e92:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e96:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e9a:	ee                   	out    %al,(%dx)
}
c0100e9b:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e9c:	c7 05 24 34 1a c0 00 	movl   $0x0,0xc01a3424
c0100ea3:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100ea6:	83 ec 0c             	sub    $0xc,%esp
c0100ea9:	68 a4 b7 10 c0       	push   $0xc010b7a4
c0100eae:	e8 95 f4 ff ff       	call   c0100348 <cprintf>
c0100eb3:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0100eb6:	83 ec 0c             	sub    $0xc,%esp
c0100eb9:	6a 00                	push   $0x0
c0100ebb:	e8 2e 11 00 00       	call   c0101fee <pic_enable>
c0100ec0:	83 c4 10             	add    $0x10,%esp
}
c0100ec3:	90                   	nop
c0100ec4:	c9                   	leave  
c0100ec5:	c3                   	ret    

c0100ec6 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100ec6:	55                   	push   %ebp
c0100ec7:	89 e5                	mov    %esp,%ebp
c0100ec9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100ecc:	9c                   	pushf  
c0100ecd:	58                   	pop    %eax
c0100ece:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100ed4:	25 00 02 00 00       	and    $0x200,%eax
c0100ed9:	85 c0                	test   %eax,%eax
c0100edb:	74 0c                	je     c0100ee9 <__intr_save+0x23>
        intr_disable();
c0100edd:	e8 a9 10 00 00       	call   c0101f8b <intr_disable>
        return 1;
c0100ee2:	b8 01 00 00 00       	mov    $0x1,%eax
c0100ee7:	eb 05                	jmp    c0100eee <__intr_save+0x28>
    }
    return 0;
c0100ee9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100eee:	c9                   	leave  
c0100eef:	c3                   	ret    

c0100ef0 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100ef0:	55                   	push   %ebp
c0100ef1:	89 e5                	mov    %esp,%ebp
c0100ef3:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100ef6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100efa:	74 05                	je     c0100f01 <__intr_restore+0x11>
        intr_enable();
c0100efc:	e8 82 10 00 00       	call   c0101f83 <intr_enable>
    }
}
c0100f01:	90                   	nop
c0100f02:	c9                   	leave  
c0100f03:	c3                   	ret    

c0100f04 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f04:	55                   	push   %ebp
c0100f05:	89 e5                	mov    %esp,%ebp
c0100f07:	83 ec 10             	sub    $0x10,%esp
c0100f0a:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f10:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f14:	89 c2                	mov    %eax,%edx
c0100f16:	ec                   	in     (%dx),%al
c0100f17:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100f1a:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f20:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f24:	89 c2                	mov    %eax,%edx
c0100f26:	ec                   	in     (%dx),%al
c0100f27:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100f2a:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f30:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f34:	89 c2                	mov    %eax,%edx
c0100f36:	ec                   	in     (%dx),%al
c0100f37:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100f3a:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100f40:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100f44:	89 c2                	mov    %eax,%edx
c0100f46:	ec                   	in     (%dx),%al
c0100f47:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100f4a:	90                   	nop
c0100f4b:	c9                   	leave  
c0100f4c:	c3                   	ret    

c0100f4d <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100f4d:	55                   	push   %ebp
c0100f4e:	89 e5                	mov    %esp,%ebp
c0100f50:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100f53:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f5d:	0f b7 00             	movzwl (%eax),%eax
c0100f60:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f64:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f67:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f6f:	0f b7 00             	movzwl (%eax),%eax
c0100f72:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100f76:	74 12                	je     c0100f8a <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f78:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f7f:	66 c7 05 46 34 1a c0 	movw   $0x3b4,0xc01a3446
c0100f86:	b4 03 
c0100f88:	eb 13                	jmp    c0100f9d <cga_init+0x50>
    } else {
        *cp = was;
c0100f8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f8d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f91:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f94:	66 c7 05 46 34 1a c0 	movw   $0x3d4,0xc01a3446
c0100f9b:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f9d:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c0100fa4:	0f b7 c0             	movzwl %ax,%eax
c0100fa7:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100fab:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100faf:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fb3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fb7:	ee                   	out    %al,(%dx)
}
c0100fb8:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100fb9:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c0100fc0:	83 c0 01             	add    $0x1,%eax
c0100fc3:	0f b7 c0             	movzwl %ax,%eax
c0100fc6:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fca:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fce:	89 c2                	mov    %eax,%edx
c0100fd0:	ec                   	in     (%dx),%al
c0100fd1:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100fd4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fd8:	0f b6 c0             	movzbl %al,%eax
c0100fdb:	c1 e0 08             	shl    $0x8,%eax
c0100fde:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100fe1:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c0100fe8:	0f b7 c0             	movzwl %ax,%eax
c0100feb:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100fef:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ff3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ff7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ffb:	ee                   	out    %al,(%dx)
}
c0100ffc:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100ffd:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c0101004:	83 c0 01             	add    $0x1,%eax
c0101007:	0f b7 c0             	movzwl %ax,%eax
c010100a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101012:	89 c2                	mov    %eax,%edx
c0101014:	ec                   	in     (%dx),%al
c0101015:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0101018:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010101c:	0f b6 c0             	movzbl %al,%eax
c010101f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101022:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101025:	a3 40 34 1a c0       	mov    %eax,0xc01a3440
    crt_pos = pos;
c010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010102d:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
}
c0101033:	90                   	nop
c0101034:	c9                   	leave  
c0101035:	c3                   	ret    

c0101036 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101036:	55                   	push   %ebp
c0101037:	89 e5                	mov    %esp,%ebp
c0101039:	83 ec 38             	sub    $0x38,%esp
c010103c:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0101042:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101046:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010104a:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010104e:	ee                   	out    %al,(%dx)
}
c010104f:	90                   	nop
c0101050:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0101056:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010105a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010105e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101062:	ee                   	out    %al,(%dx)
}
c0101063:	90                   	nop
c0101064:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c010106a:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010106e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101072:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101076:	ee                   	out    %al,(%dx)
}
c0101077:	90                   	nop
c0101078:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010107e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101082:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101086:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010108a:	ee                   	out    %al,(%dx)
}
c010108b:	90                   	nop
c010108c:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101092:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101096:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010109a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010109e:	ee                   	out    %al,(%dx)
}
c010109f:	90                   	nop
c01010a0:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c01010a6:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010aa:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01010ae:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01010b2:	ee                   	out    %al,(%dx)
}
c01010b3:	90                   	nop
c01010b4:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01010ba:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010be:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01010c2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
}
c01010c7:	90                   	nop
c01010c8:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01010ce:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01010d2:	89 c2                	mov    %eax,%edx
c01010d4:	ec                   	in     (%dx),%al
c01010d5:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01010d8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c01010dc:	3c ff                	cmp    $0xff,%al
c01010de:	0f 95 c0             	setne  %al
c01010e1:	0f b6 c0             	movzbl %al,%eax
c01010e4:	a3 48 34 1a c0       	mov    %eax,0xc01a3448
c01010e9:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01010ef:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01010f3:	89 c2                	mov    %eax,%edx
c01010f5:	ec                   	in     (%dx),%al
c01010f6:	88 45 f1             	mov    %al,-0xf(%ebp)
c01010f9:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01010ff:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101103:	89 c2                	mov    %eax,%edx
c0101105:	ec                   	in     (%dx),%al
c0101106:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101109:	a1 48 34 1a c0       	mov    0xc01a3448,%eax
c010110e:	85 c0                	test   %eax,%eax
c0101110:	74 0d                	je     c010111f <serial_init+0xe9>
        pic_enable(IRQ_COM1);
c0101112:	83 ec 0c             	sub    $0xc,%esp
c0101115:	6a 04                	push   $0x4
c0101117:	e8 d2 0e 00 00       	call   c0101fee <pic_enable>
c010111c:	83 c4 10             	add    $0x10,%esp
    }
}
c010111f:	90                   	nop
c0101120:	c9                   	leave  
c0101121:	c3                   	ret    

c0101122 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101122:	55                   	push   %ebp
c0101123:	89 e5                	mov    %esp,%ebp
c0101125:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101128:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010112f:	eb 09                	jmp    c010113a <lpt_putc_sub+0x18>
        delay();
c0101131:	e8 ce fd ff ff       	call   c0100f04 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101136:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010113a:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101140:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101144:	89 c2                	mov    %eax,%edx
c0101146:	ec                   	in     (%dx),%al
c0101147:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010114a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010114e:	84 c0                	test   %al,%al
c0101150:	78 09                	js     c010115b <lpt_putc_sub+0x39>
c0101152:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101159:	7e d6                	jle    c0101131 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c010115b:	8b 45 08             	mov    0x8(%ebp),%eax
c010115e:	0f b6 c0             	movzbl %al,%eax
c0101161:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101167:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010116a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010116e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101172:	ee                   	out    %al,(%dx)
}
c0101173:	90                   	nop
c0101174:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c010117a:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010117e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101182:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101186:	ee                   	out    %al,(%dx)
}
c0101187:	90                   	nop
c0101188:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010118e:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101192:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101196:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010119a:	ee                   	out    %al,(%dx)
}
c010119b:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010119c:	90                   	nop
c010119d:	c9                   	leave  
c010119e:	c3                   	ret    

c010119f <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010119f:	55                   	push   %ebp
c01011a0:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c01011a2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01011a6:	74 0d                	je     c01011b5 <lpt_putc+0x16>
        lpt_putc_sub(c);
c01011a8:	ff 75 08             	pushl  0x8(%ebp)
c01011ab:	e8 72 ff ff ff       	call   c0101122 <lpt_putc_sub>
c01011b0:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01011b3:	eb 1e                	jmp    c01011d3 <lpt_putc+0x34>
        lpt_putc_sub('\b');
c01011b5:	6a 08                	push   $0x8
c01011b7:	e8 66 ff ff ff       	call   c0101122 <lpt_putc_sub>
c01011bc:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c01011bf:	6a 20                	push   $0x20
c01011c1:	e8 5c ff ff ff       	call   c0101122 <lpt_putc_sub>
c01011c6:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c01011c9:	6a 08                	push   $0x8
c01011cb:	e8 52 ff ff ff       	call   c0101122 <lpt_putc_sub>
c01011d0:	83 c4 04             	add    $0x4,%esp
}
c01011d3:	90                   	nop
c01011d4:	c9                   	leave  
c01011d5:	c3                   	ret    

c01011d6 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01011d6:	55                   	push   %ebp
c01011d7:	89 e5                	mov    %esp,%ebp
c01011d9:	53                   	push   %ebx
c01011da:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01011dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e0:	b0 00                	mov    $0x0,%al
c01011e2:	85 c0                	test   %eax,%eax
c01011e4:	75 07                	jne    c01011ed <cga_putc+0x17>
        c |= 0x0700;
c01011e6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01011ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f0:	0f b6 c0             	movzbl %al,%eax
c01011f3:	83 f8 0d             	cmp    $0xd,%eax
c01011f6:	74 6b                	je     c0101263 <cga_putc+0x8d>
c01011f8:	83 f8 0d             	cmp    $0xd,%eax
c01011fb:	0f 8f 9c 00 00 00    	jg     c010129d <cga_putc+0xc7>
c0101201:	83 f8 08             	cmp    $0x8,%eax
c0101204:	74 0a                	je     c0101210 <cga_putc+0x3a>
c0101206:	83 f8 0a             	cmp    $0xa,%eax
c0101209:	74 48                	je     c0101253 <cga_putc+0x7d>
c010120b:	e9 8d 00 00 00       	jmp    c010129d <cga_putc+0xc7>
    case '\b':
        if (crt_pos > 0) {
c0101210:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c0101217:	66 85 c0             	test   %ax,%ax
c010121a:	0f 84 a3 00 00 00    	je     c01012c3 <cga_putc+0xed>
            crt_pos --;
c0101220:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c0101227:	83 e8 01             	sub    $0x1,%eax
c010122a:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101230:	8b 45 08             	mov    0x8(%ebp),%eax
c0101233:	b0 00                	mov    $0x0,%al
c0101235:	83 c8 20             	or     $0x20,%eax
c0101238:	89 c2                	mov    %eax,%edx
c010123a:	8b 0d 40 34 1a c0    	mov    0xc01a3440,%ecx
c0101240:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c0101247:	0f b7 c0             	movzwl %ax,%eax
c010124a:	01 c0                	add    %eax,%eax
c010124c:	01 c8                	add    %ecx,%eax
c010124e:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0101251:	eb 70                	jmp    c01012c3 <cga_putc+0xed>
    case '\n':
        crt_pos += CRT_COLS;
c0101253:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c010125a:	83 c0 50             	add    $0x50,%eax
c010125d:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101263:	0f b7 1d 44 34 1a c0 	movzwl 0xc01a3444,%ebx
c010126a:	0f b7 0d 44 34 1a c0 	movzwl 0xc01a3444,%ecx
c0101271:	0f b7 c1             	movzwl %cx,%eax
c0101274:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010127a:	c1 e8 10             	shr    $0x10,%eax
c010127d:	89 c2                	mov    %eax,%edx
c010127f:	66 c1 ea 06          	shr    $0x6,%dx
c0101283:	89 d0                	mov    %edx,%eax
c0101285:	c1 e0 02             	shl    $0x2,%eax
c0101288:	01 d0                	add    %edx,%eax
c010128a:	c1 e0 04             	shl    $0x4,%eax
c010128d:	29 c1                	sub    %eax,%ecx
c010128f:	89 ca                	mov    %ecx,%edx
c0101291:	89 d8                	mov    %ebx,%eax
c0101293:	29 d0                	sub    %edx,%eax
c0101295:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
        break;
c010129b:	eb 27                	jmp    c01012c4 <cga_putc+0xee>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010129d:	8b 0d 40 34 1a c0    	mov    0xc01a3440,%ecx
c01012a3:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c01012aa:	8d 50 01             	lea    0x1(%eax),%edx
c01012ad:	66 89 15 44 34 1a c0 	mov    %dx,0xc01a3444
c01012b4:	0f b7 c0             	movzwl %ax,%eax
c01012b7:	01 c0                	add    %eax,%eax
c01012b9:	01 c8                	add    %ecx,%eax
c01012bb:	8b 55 08             	mov    0x8(%ebp),%edx
c01012be:	66 89 10             	mov    %dx,(%eax)
        break;
c01012c1:	eb 01                	jmp    c01012c4 <cga_putc+0xee>
        break;
c01012c3:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01012c4:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c01012cb:	66 3d cf 07          	cmp    $0x7cf,%ax
c01012cf:	76 5a                	jbe    c010132b <cga_putc+0x155>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01012d1:	a1 40 34 1a c0       	mov    0xc01a3440,%eax
c01012d6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01012dc:	a1 40 34 1a c0       	mov    0xc01a3440,%eax
c01012e1:	83 ec 04             	sub    $0x4,%esp
c01012e4:	68 00 0f 00 00       	push   $0xf00
c01012e9:	52                   	push   %edx
c01012ea:	50                   	push   %eax
c01012eb:	e8 32 a0 00 00       	call   c010b322 <memmove>
c01012f0:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012f3:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012fa:	eb 16                	jmp    c0101312 <cga_putc+0x13c>
            crt_buf[i] = 0x0700 | ' ';
c01012fc:	8b 15 40 34 1a c0    	mov    0xc01a3440,%edx
c0101302:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101305:	01 c0                	add    %eax,%eax
c0101307:	01 d0                	add    %edx,%eax
c0101309:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010130e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101312:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101319:	7e e1                	jle    c01012fc <cga_putc+0x126>
        }
        crt_pos -= CRT_COLS;
c010131b:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c0101322:	83 e8 50             	sub    $0x50,%eax
c0101325:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010132b:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c0101332:	0f b7 c0             	movzwl %ax,%eax
c0101335:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101339:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010133d:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101341:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101345:	ee                   	out    %al,(%dx)
}
c0101346:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101347:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c010134e:	66 c1 e8 08          	shr    $0x8,%ax
c0101352:	0f b6 c0             	movzbl %al,%eax
c0101355:	0f b7 15 46 34 1a c0 	movzwl 0xc01a3446,%edx
c010135c:	83 c2 01             	add    $0x1,%edx
c010135f:	0f b7 d2             	movzwl %dx,%edx
c0101362:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101366:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101369:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010136d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101371:	ee                   	out    %al,(%dx)
}
c0101372:	90                   	nop
    outb(addr_6845, 15);
c0101373:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c010137a:	0f b7 c0             	movzwl %ax,%eax
c010137d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101381:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101385:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101389:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010138d:	ee                   	out    %al,(%dx)
}
c010138e:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c010138f:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c0101396:	0f b6 c0             	movzbl %al,%eax
c0101399:	0f b7 15 46 34 1a c0 	movzwl 0xc01a3446,%edx
c01013a0:	83 c2 01             	add    $0x1,%edx
c01013a3:	0f b7 d2             	movzwl %dx,%edx
c01013a6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c01013aa:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013ad:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01013b1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013b5:	ee                   	out    %al,(%dx)
}
c01013b6:	90                   	nop
}
c01013b7:	90                   	nop
c01013b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01013bb:	c9                   	leave  
c01013bc:	c3                   	ret    

c01013bd <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01013bd:	55                   	push   %ebp
c01013be:	89 e5                	mov    %esp,%ebp
c01013c0:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01013ca:	eb 09                	jmp    c01013d5 <serial_putc_sub+0x18>
        delay();
c01013cc:	e8 33 fb ff ff       	call   c0100f04 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01013d5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013db:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013df:	89 c2                	mov    %eax,%edx
c01013e1:	ec                   	in     (%dx),%al
c01013e2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013e5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013e9:	0f b6 c0             	movzbl %al,%eax
c01013ec:	83 e0 20             	and    $0x20,%eax
c01013ef:	85 c0                	test   %eax,%eax
c01013f1:	75 09                	jne    c01013fc <serial_putc_sub+0x3f>
c01013f3:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013fa:	7e d0                	jle    c01013cc <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c01013fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01013ff:	0f b6 c0             	movzbl %al,%eax
c0101402:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101408:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010140b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010140f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101413:	ee                   	out    %al,(%dx)
}
c0101414:	90                   	nop
}
c0101415:	90                   	nop
c0101416:	c9                   	leave  
c0101417:	c3                   	ret    

c0101418 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101418:	55                   	push   %ebp
c0101419:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c010141b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010141f:	74 0d                	je     c010142e <serial_putc+0x16>
        serial_putc_sub(c);
c0101421:	ff 75 08             	pushl  0x8(%ebp)
c0101424:	e8 94 ff ff ff       	call   c01013bd <serial_putc_sub>
c0101429:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010142c:	eb 1e                	jmp    c010144c <serial_putc+0x34>
        serial_putc_sub('\b');
c010142e:	6a 08                	push   $0x8
c0101430:	e8 88 ff ff ff       	call   c01013bd <serial_putc_sub>
c0101435:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0101438:	6a 20                	push   $0x20
c010143a:	e8 7e ff ff ff       	call   c01013bd <serial_putc_sub>
c010143f:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0101442:	6a 08                	push   $0x8
c0101444:	e8 74 ff ff ff       	call   c01013bd <serial_putc_sub>
c0101449:	83 c4 04             	add    $0x4,%esp
}
c010144c:	90                   	nop
c010144d:	c9                   	leave  
c010144e:	c3                   	ret    

c010144f <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010144f:	55                   	push   %ebp
c0101450:	89 e5                	mov    %esp,%ebp
c0101452:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101455:	eb 33                	jmp    c010148a <cons_intr+0x3b>
        if (c != 0) {
c0101457:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010145b:	74 2d                	je     c010148a <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010145d:	a1 64 36 1a c0       	mov    0xc01a3664,%eax
c0101462:	8d 50 01             	lea    0x1(%eax),%edx
c0101465:	89 15 64 36 1a c0    	mov    %edx,0xc01a3664
c010146b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010146e:	88 90 60 34 1a c0    	mov    %dl,-0x3fe5cba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101474:	a1 64 36 1a c0       	mov    0xc01a3664,%eax
c0101479:	3d 00 02 00 00       	cmp    $0x200,%eax
c010147e:	75 0a                	jne    c010148a <cons_intr+0x3b>
                cons.wpos = 0;
c0101480:	c7 05 64 36 1a c0 00 	movl   $0x0,0xc01a3664
c0101487:	00 00 00 
    while ((c = (*proc)()) != -1) {
c010148a:	8b 45 08             	mov    0x8(%ebp),%eax
c010148d:	ff d0                	call   *%eax
c010148f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101492:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101496:	75 bf                	jne    c0101457 <cons_intr+0x8>
            }
        }
    }
}
c0101498:	90                   	nop
c0101499:	90                   	nop
c010149a:	c9                   	leave  
c010149b:	c3                   	ret    

c010149c <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010149c:	55                   	push   %ebp
c010149d:	89 e5                	mov    %esp,%ebp
c010149f:	83 ec 10             	sub    $0x10,%esp
c01014a2:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014a8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01014ac:	89 c2                	mov    %eax,%edx
c01014ae:	ec                   	in     (%dx),%al
c01014af:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01014b2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01014b6:	0f b6 c0             	movzbl %al,%eax
c01014b9:	83 e0 01             	and    $0x1,%eax
c01014bc:	85 c0                	test   %eax,%eax
c01014be:	75 07                	jne    c01014c7 <serial_proc_data+0x2b>
        return -1;
c01014c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014c5:	eb 2a                	jmp    c01014f1 <serial_proc_data+0x55>
c01014c7:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014cd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01014d1:	89 c2                	mov    %eax,%edx
c01014d3:	ec                   	in     (%dx),%al
c01014d4:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014d7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014db:	0f b6 c0             	movzbl %al,%eax
c01014de:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014e1:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014e5:	75 07                	jne    c01014ee <serial_proc_data+0x52>
        c = '\b';
c01014e7:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014f1:	c9                   	leave  
c01014f2:	c3                   	ret    

c01014f3 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014f3:	55                   	push   %ebp
c01014f4:	89 e5                	mov    %esp,%ebp
c01014f6:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c01014f9:	a1 48 34 1a c0       	mov    0xc01a3448,%eax
c01014fe:	85 c0                	test   %eax,%eax
c0101500:	74 10                	je     c0101512 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0101502:	83 ec 0c             	sub    $0xc,%esp
c0101505:	68 9c 14 10 c0       	push   $0xc010149c
c010150a:	e8 40 ff ff ff       	call   c010144f <cons_intr>
c010150f:	83 c4 10             	add    $0x10,%esp
    }
}
c0101512:	90                   	nop
c0101513:	c9                   	leave  
c0101514:	c3                   	ret    

c0101515 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101515:	55                   	push   %ebp
c0101516:	89 e5                	mov    %esp,%ebp
c0101518:	83 ec 28             	sub    $0x28,%esp
c010151b:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101521:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101525:	89 c2                	mov    %eax,%edx
c0101527:	ec                   	in     (%dx),%al
c0101528:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010152b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010152f:	0f b6 c0             	movzbl %al,%eax
c0101532:	83 e0 01             	and    $0x1,%eax
c0101535:	85 c0                	test   %eax,%eax
c0101537:	75 0a                	jne    c0101543 <kbd_proc_data+0x2e>
        return -1;
c0101539:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010153e:	e9 5e 01 00 00       	jmp    c01016a1 <kbd_proc_data+0x18c>
c0101543:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101549:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010154d:	89 c2                	mov    %eax,%edx
c010154f:	ec                   	in     (%dx),%al
c0101550:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101553:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101557:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010155a:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010155e:	75 17                	jne    c0101577 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101560:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101565:	83 c8 40             	or     $0x40,%eax
c0101568:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
        return 0;
c010156d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101572:	e9 2a 01 00 00       	jmp    c01016a1 <kbd_proc_data+0x18c>
    } else if (data & 0x80) {
c0101577:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010157b:	84 c0                	test   %al,%al
c010157d:	79 47                	jns    c01015c6 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010157f:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101584:	83 e0 40             	and    $0x40,%eax
c0101587:	85 c0                	test   %eax,%eax
c0101589:	75 09                	jne    c0101594 <kbd_proc_data+0x7f>
c010158b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010158f:	83 e0 7f             	and    $0x7f,%eax
c0101592:	eb 04                	jmp    c0101598 <kbd_proc_data+0x83>
c0101594:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101598:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c010159b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010159f:	0f b6 80 40 f0 12 c0 	movzbl -0x3fed0fc0(%eax),%eax
c01015a6:	83 c8 40             	or     $0x40,%eax
c01015a9:	0f b6 c0             	movzbl %al,%eax
c01015ac:	f7 d0                	not    %eax
c01015ae:	89 c2                	mov    %eax,%edx
c01015b0:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01015b5:	21 d0                	and    %edx,%eax
c01015b7:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
        return 0;
c01015bc:	b8 00 00 00 00       	mov    $0x0,%eax
c01015c1:	e9 db 00 00 00       	jmp    c01016a1 <kbd_proc_data+0x18c>
    } else if (shift & E0ESC) {
c01015c6:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01015cb:	83 e0 40             	and    $0x40,%eax
c01015ce:	85 c0                	test   %eax,%eax
c01015d0:	74 11                	je     c01015e3 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01015d2:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01015d6:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01015db:	83 e0 bf             	and    $0xffffffbf,%eax
c01015de:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
    }

    shift |= shiftcode[data];
c01015e3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015e7:	0f b6 80 40 f0 12 c0 	movzbl -0x3fed0fc0(%eax),%eax
c01015ee:	0f b6 d0             	movzbl %al,%edx
c01015f1:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01015f6:	09 d0                	or     %edx,%eax
c01015f8:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
    shift ^= togglecode[data];
c01015fd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101601:	0f b6 80 40 f1 12 c0 	movzbl -0x3fed0ec0(%eax),%eax
c0101608:	0f b6 d0             	movzbl %al,%edx
c010160b:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101610:	31 d0                	xor    %edx,%eax
c0101612:	a3 68 36 1a c0       	mov    %eax,0xc01a3668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101617:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c010161c:	83 e0 03             	and    $0x3,%eax
c010161f:	8b 14 85 40 f5 12 c0 	mov    -0x3fed0ac0(,%eax,4),%edx
c0101626:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010162a:	01 d0                	add    %edx,%eax
c010162c:	0f b6 00             	movzbl (%eax),%eax
c010162f:	0f b6 c0             	movzbl %al,%eax
c0101632:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101635:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c010163a:	83 e0 08             	and    $0x8,%eax
c010163d:	85 c0                	test   %eax,%eax
c010163f:	74 22                	je     c0101663 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101641:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101645:	7e 0c                	jle    c0101653 <kbd_proc_data+0x13e>
c0101647:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010164b:	7f 06                	jg     c0101653 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010164d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101651:	eb 10                	jmp    c0101663 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101653:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101657:	7e 0a                	jle    c0101663 <kbd_proc_data+0x14e>
c0101659:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010165d:	7f 04                	jg     c0101663 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010165f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101663:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101668:	f7 d0                	not    %eax
c010166a:	83 e0 06             	and    $0x6,%eax
c010166d:	85 c0                	test   %eax,%eax
c010166f:	75 2d                	jne    c010169e <kbd_proc_data+0x189>
c0101671:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101678:	75 24                	jne    c010169e <kbd_proc_data+0x189>
        cprintf("Rebooting!\n");
c010167a:	83 ec 0c             	sub    $0xc,%esp
c010167d:	68 bf b7 10 c0       	push   $0xc010b7bf
c0101682:	e8 c1 ec ff ff       	call   c0100348 <cprintf>
c0101687:	83 c4 10             	add    $0x10,%esp
c010168a:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101690:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101694:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101698:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c010169c:	ee                   	out    %al,(%dx)
}
c010169d:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010169e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016a1:	c9                   	leave  
c01016a2:	c3                   	ret    

c01016a3 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01016a3:	55                   	push   %ebp
c01016a4:	89 e5                	mov    %esp,%ebp
c01016a6:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c01016a9:	83 ec 0c             	sub    $0xc,%esp
c01016ac:	68 15 15 10 c0       	push   $0xc0101515
c01016b1:	e8 99 fd ff ff       	call   c010144f <cons_intr>
c01016b6:	83 c4 10             	add    $0x10,%esp
}
c01016b9:	90                   	nop
c01016ba:	c9                   	leave  
c01016bb:	c3                   	ret    

c01016bc <kbd_init>:

static void
kbd_init(void) {
c01016bc:	55                   	push   %ebp
c01016bd:	89 e5                	mov    %esp,%ebp
c01016bf:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c01016c2:	e8 dc ff ff ff       	call   c01016a3 <kbd_intr>
    pic_enable(IRQ_KBD);
c01016c7:	83 ec 0c             	sub    $0xc,%esp
c01016ca:	6a 01                	push   $0x1
c01016cc:	e8 1d 09 00 00       	call   c0101fee <pic_enable>
c01016d1:	83 c4 10             	add    $0x10,%esp
}
c01016d4:	90                   	nop
c01016d5:	c9                   	leave  
c01016d6:	c3                   	ret    

c01016d7 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01016d7:	55                   	push   %ebp
c01016d8:	89 e5                	mov    %esp,%ebp
c01016da:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c01016dd:	e8 6b f8 ff ff       	call   c0100f4d <cga_init>
    serial_init();
c01016e2:	e8 4f f9 ff ff       	call   c0101036 <serial_init>
    kbd_init();
c01016e7:	e8 d0 ff ff ff       	call   c01016bc <kbd_init>
    if (!serial_exists) {
c01016ec:	a1 48 34 1a c0       	mov    0xc01a3448,%eax
c01016f1:	85 c0                	test   %eax,%eax
c01016f3:	75 10                	jne    c0101705 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c01016f5:	83 ec 0c             	sub    $0xc,%esp
c01016f8:	68 cb b7 10 c0       	push   $0xc010b7cb
c01016fd:	e8 46 ec ff ff       	call   c0100348 <cprintf>
c0101702:	83 c4 10             	add    $0x10,%esp
    }
}
c0101705:	90                   	nop
c0101706:	c9                   	leave  
c0101707:	c3                   	ret    

c0101708 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101708:	55                   	push   %ebp
c0101709:	89 e5                	mov    %esp,%ebp
c010170b:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010170e:	e8 b3 f7 ff ff       	call   c0100ec6 <__intr_save>
c0101713:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101716:	83 ec 0c             	sub    $0xc,%esp
c0101719:	ff 75 08             	pushl  0x8(%ebp)
c010171c:	e8 7e fa ff ff       	call   c010119f <lpt_putc>
c0101721:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c0101724:	83 ec 0c             	sub    $0xc,%esp
c0101727:	ff 75 08             	pushl  0x8(%ebp)
c010172a:	e8 a7 fa ff ff       	call   c01011d6 <cga_putc>
c010172f:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c0101732:	83 ec 0c             	sub    $0xc,%esp
c0101735:	ff 75 08             	pushl  0x8(%ebp)
c0101738:	e8 db fc ff ff       	call   c0101418 <serial_putc>
c010173d:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0101740:	83 ec 0c             	sub    $0xc,%esp
c0101743:	ff 75 f4             	pushl  -0xc(%ebp)
c0101746:	e8 a5 f7 ff ff       	call   c0100ef0 <__intr_restore>
c010174b:	83 c4 10             	add    $0x10,%esp
}
c010174e:	90                   	nop
c010174f:	c9                   	leave  
c0101750:	c3                   	ret    

c0101751 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101751:	55                   	push   %ebp
c0101752:	89 e5                	mov    %esp,%ebp
c0101754:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c0101757:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010175e:	e8 63 f7 ff ff       	call   c0100ec6 <__intr_save>
c0101763:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101766:	e8 88 fd ff ff       	call   c01014f3 <serial_intr>
        kbd_intr();
c010176b:	e8 33 ff ff ff       	call   c01016a3 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101770:	8b 15 60 36 1a c0    	mov    0xc01a3660,%edx
c0101776:	a1 64 36 1a c0       	mov    0xc01a3664,%eax
c010177b:	39 c2                	cmp    %eax,%edx
c010177d:	74 31                	je     c01017b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010177f:	a1 60 36 1a c0       	mov    0xc01a3660,%eax
c0101784:	8d 50 01             	lea    0x1(%eax),%edx
c0101787:	89 15 60 36 1a c0    	mov    %edx,0xc01a3660
c010178d:	0f b6 80 60 34 1a c0 	movzbl -0x3fe5cba0(%eax),%eax
c0101794:	0f b6 c0             	movzbl %al,%eax
c0101797:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010179a:	a1 60 36 1a c0       	mov    0xc01a3660,%eax
c010179f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01017a4:	75 0a                	jne    c01017b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01017a6:	c7 05 60 36 1a c0 00 	movl   $0x0,0xc01a3660
c01017ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01017b0:	83 ec 0c             	sub    $0xc,%esp
c01017b3:	ff 75 f0             	pushl  -0x10(%ebp)
c01017b6:	e8 35 f7 ff ff       	call   c0100ef0 <__intr_restore>
c01017bb:	83 c4 10             	add    $0x10,%esp
    return c;
c01017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017c1:	c9                   	leave  
c01017c2:	c3                   	ret    

c01017c3 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01017c3:	55                   	push   %ebp
c01017c4:	89 e5                	mov    %esp,%ebp
c01017c6:	83 ec 14             	sub    $0x14,%esp
c01017c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01017cc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01017d0:	90                   	nop
c01017d1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017d5:	83 c0 07             	add    $0x7,%eax
c01017d8:	0f b7 c0             	movzwl %ax,%eax
c01017db:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017df:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017e3:	89 c2                	mov    %eax,%edx
c01017e5:	ec                   	in     (%dx),%al
c01017e6:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01017e9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017ed:	0f b6 c0             	movzbl %al,%eax
c01017f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01017f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017f6:	25 80 00 00 00       	and    $0x80,%eax
c01017fb:	85 c0                	test   %eax,%eax
c01017fd:	75 d2                	jne    c01017d1 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c01017ff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101803:	74 11                	je     c0101816 <ide_wait_ready+0x53>
c0101805:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101808:	83 e0 21             	and    $0x21,%eax
c010180b:	85 c0                	test   %eax,%eax
c010180d:	74 07                	je     c0101816 <ide_wait_ready+0x53>
        return -1;
c010180f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101814:	eb 05                	jmp    c010181b <ide_wait_ready+0x58>
    }
    return 0;
c0101816:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010181b:	c9                   	leave  
c010181c:	c3                   	ret    

c010181d <ide_init>:

void
ide_init(void) {
c010181d:	55                   	push   %ebp
c010181e:	89 e5                	mov    %esp,%ebp
c0101820:	57                   	push   %edi
c0101821:	53                   	push   %ebx
c0101822:	81 ec 40 02 00 00    	sub    $0x240,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101828:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c010182e:	e9 6b 02 00 00       	jmp    c0101a9e <ide_init+0x281>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101833:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101837:	6b c0 38             	imul   $0x38,%eax,%eax
c010183a:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c010183f:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0101842:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101846:	66 d1 e8             	shr    %ax
c0101849:	0f b7 c0             	movzwl %ax,%eax
c010184c:	0f b7 04 85 ec b7 10 	movzwl -0x3fef4814(,%eax,4),%eax
c0101853:	c0 
c0101854:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101858:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010185c:	6a 00                	push   $0x0
c010185e:	50                   	push   %eax
c010185f:	e8 5f ff ff ff       	call   c01017c3 <ide_wait_ready>
c0101864:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0101867:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010186b:	c1 e0 04             	shl    $0x4,%eax
c010186e:	83 e0 10             	and    $0x10,%eax
c0101871:	83 c8 e0             	or     $0xffffffe0,%eax
c0101874:	0f b6 c0             	movzbl %al,%eax
c0101877:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010187b:	83 c2 06             	add    $0x6,%edx
c010187e:	0f b7 d2             	movzwl %dx,%edx
c0101881:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0101885:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101888:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010188c:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101890:	ee                   	out    %al,(%dx)
}
c0101891:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101892:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101896:	6a 00                	push   $0x0
c0101898:	50                   	push   %eax
c0101899:	e8 25 ff ff ff       	call   c01017c3 <ide_wait_ready>
c010189e:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01018a1:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018a5:	83 c0 07             	add    $0x7,%eax
c01018a8:	0f b7 c0             	movzwl %ax,%eax
c01018ab:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01018af:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018b3:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01018b7:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01018bb:	ee                   	out    %al,(%dx)
}
c01018bc:	90                   	nop
        ide_wait_ready(iobase, 0);
c01018bd:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018c1:	6a 00                	push   $0x0
c01018c3:	50                   	push   %eax
c01018c4:	e8 fa fe ff ff       	call   c01017c3 <ide_wait_ready>
c01018c9:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01018cc:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018d0:	83 c0 07             	add    $0x7,%eax
c01018d3:	0f b7 c0             	movzwl %ax,%eax
c01018d6:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018da:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01018de:	89 c2                	mov    %eax,%edx
c01018e0:	ec                   	in     (%dx),%al
c01018e1:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c01018e4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01018e8:	84 c0                	test   %al,%al
c01018ea:	0f 84 a2 01 00 00    	je     c0101a92 <ide_init+0x275>
c01018f0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018f4:	6a 01                	push   $0x1
c01018f6:	50                   	push   %eax
c01018f7:	e8 c7 fe ff ff       	call   c01017c3 <ide_wait_ready>
c01018fc:	83 c4 08             	add    $0x8,%esp
c01018ff:	85 c0                	test   %eax,%eax
c0101901:	0f 85 8b 01 00 00    	jne    c0101a92 <ide_init+0x275>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101907:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010190b:	6b c0 38             	imul   $0x38,%eax,%eax
c010190e:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101913:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101916:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010191a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010191d:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101923:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101926:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c010192d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101930:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101933:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101936:	89 cb                	mov    %ecx,%ebx
c0101938:	89 df                	mov    %ebx,%edi
c010193a:	89 c1                	mov    %eax,%ecx
c010193c:	fc                   	cld    
c010193d:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010193f:	89 c8                	mov    %ecx,%eax
c0101941:	89 fb                	mov    %edi,%ebx
c0101943:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101946:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c0101949:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c010194a:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101950:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101953:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101956:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010195c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010195f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101962:	25 00 00 00 04       	and    $0x4000000,%eax
c0101967:	85 c0                	test   %eax,%eax
c0101969:	74 0e                	je     c0101979 <ide_init+0x15c>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010196b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010196e:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101974:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101977:	eb 09                	jmp    c0101982 <ide_init+0x165>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101979:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010197c:	8b 40 78             	mov    0x78(%eax),%eax
c010197f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101982:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101986:	6b c0 38             	imul   $0x38,%eax,%eax
c0101989:	8d 90 84 36 1a c0    	lea    -0x3fe5c97c(%eax),%edx
c010198f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101992:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0101994:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101998:	6b c0 38             	imul   $0x38,%eax,%eax
c010199b:	8d 90 88 36 1a c0    	lea    -0x3fe5c978(%eax),%edx
c01019a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019a4:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01019a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019a9:	83 c0 62             	add    $0x62,%eax
c01019ac:	0f b7 00             	movzwl (%eax),%eax
c01019af:	0f b7 c0             	movzwl %ax,%eax
c01019b2:	25 00 02 00 00       	and    $0x200,%eax
c01019b7:	85 c0                	test   %eax,%eax
c01019b9:	75 16                	jne    c01019d1 <ide_init+0x1b4>
c01019bb:	68 f4 b7 10 c0       	push   $0xc010b7f4
c01019c0:	68 37 b8 10 c0       	push   $0xc010b837
c01019c5:	6a 7d                	push   $0x7d
c01019c7:	68 4c b8 10 c0       	push   $0xc010b84c
c01019cc:	e8 b5 f3 ff ff       	call   c0100d86 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01019d1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019d5:	6b c0 38             	imul   $0x38,%eax,%eax
c01019d8:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c01019dd:	83 c0 0c             	add    $0xc,%eax
c01019e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01019e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019e6:	83 c0 36             	add    $0x36,%eax
c01019e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01019ec:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c01019f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01019fa:	eb 34                	jmp    c0101a30 <ide_init+0x213>
            model[i] = data[i + 1], model[i + 1] = data[i];
c01019fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019ff:	8d 50 01             	lea    0x1(%eax),%edx
c0101a02:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a05:	01 d0                	add    %edx,%eax
c0101a07:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101a0a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101a0d:	01 ca                	add    %ecx,%edx
c0101a0f:	0f b6 00             	movzbl (%eax),%eax
c0101a12:	88 02                	mov    %al,(%edx)
c0101a14:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a1a:	01 d0                	add    %edx,%eax
c0101a1c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101a1f:	8d 4a 01             	lea    0x1(%edx),%ecx
c0101a22:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a25:	01 ca                	add    %ecx,%edx
c0101a27:	0f b6 00             	movzbl (%eax),%eax
c0101a2a:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0101a2c:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a33:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a36:	72 c4                	jb     c01019fc <ide_init+0x1df>
        }
        do {
            model[i] = '\0';
c0101a38:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a3e:	01 d0                	add    %edx,%eax
c0101a40:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101a43:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a46:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a49:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a4c:	85 c0                	test   %eax,%eax
c0101a4e:	74 0f                	je     c0101a5f <ide_init+0x242>
c0101a50:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a56:	01 d0                	add    %edx,%eax
c0101a58:	0f b6 00             	movzbl (%eax),%eax
c0101a5b:	3c 20                	cmp    $0x20,%al
c0101a5d:	74 d9                	je     c0101a38 <ide_init+0x21b>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101a5f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a63:	6b c0 38             	imul   $0x38,%eax,%eax
c0101a66:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101a6b:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101a6e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a72:	6b c0 38             	imul   $0x38,%eax,%eax
c0101a75:	05 88 36 1a c0       	add    $0xc01a3688,%eax
c0101a7a:	8b 10                	mov    (%eax),%edx
c0101a7c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a80:	51                   	push   %ecx
c0101a81:	52                   	push   %edx
c0101a82:	50                   	push   %eax
c0101a83:	68 5e b8 10 c0       	push   $0xc010b85e
c0101a88:	e8 bb e8 ff ff       	call   c0100348 <cprintf>
c0101a8d:	83 c4 10             	add    $0x10,%esp
c0101a90:	eb 01                	jmp    c0101a93 <ide_init+0x276>
            continue ;
c0101a92:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a93:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a97:	83 c0 01             	add    $0x1,%eax
c0101a9a:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101a9e:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101aa3:	0f 86 8a fd ff ff    	jbe    c0101833 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101aa9:	83 ec 0c             	sub    $0xc,%esp
c0101aac:	6a 0e                	push   $0xe
c0101aae:	e8 3b 05 00 00       	call   c0101fee <pic_enable>
c0101ab3:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c0101ab6:	83 ec 0c             	sub    $0xc,%esp
c0101ab9:	6a 0f                	push   $0xf
c0101abb:	e8 2e 05 00 00       	call   c0101fee <pic_enable>
c0101ac0:	83 c4 10             	add    $0x10,%esp
}
c0101ac3:	90                   	nop
c0101ac4:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101ac7:	5b                   	pop    %ebx
c0101ac8:	5f                   	pop    %edi
c0101ac9:	5d                   	pop    %ebp
c0101aca:	c3                   	ret    

c0101acb <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101acb:	55                   	push   %ebp
c0101acc:	89 e5                	mov    %esp,%ebp
c0101ace:	83 ec 04             	sub    $0x4,%esp
c0101ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101ad8:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101add:	77 1a                	ja     c0101af9 <ide_device_valid+0x2e>
c0101adf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101ae3:	6b c0 38             	imul   $0x38,%eax,%eax
c0101ae6:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101aeb:	0f b6 00             	movzbl (%eax),%eax
c0101aee:	84 c0                	test   %al,%al
c0101af0:	74 07                	je     c0101af9 <ide_device_valid+0x2e>
c0101af2:	b8 01 00 00 00       	mov    $0x1,%eax
c0101af7:	eb 05                	jmp    c0101afe <ide_device_valid+0x33>
c0101af9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101afe:	c9                   	leave  
c0101aff:	c3                   	ret    

c0101b00 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b00:	55                   	push   %ebp
c0101b01:	89 e5                	mov    %esp,%ebp
c0101b03:	83 ec 04             	sub    $0x4,%esp
c0101b06:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b09:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b0d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b11:	50                   	push   %eax
c0101b12:	e8 b4 ff ff ff       	call   c0101acb <ide_device_valid>
c0101b17:	83 c4 04             	add    $0x4,%esp
c0101b1a:	85 c0                	test   %eax,%eax
c0101b1c:	74 10                	je     c0101b2e <ide_device_size+0x2e>
        return ide_devices[ideno].size;
c0101b1e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b22:	6b c0 38             	imul   $0x38,%eax,%eax
c0101b25:	05 88 36 1a c0       	add    $0xc01a3688,%eax
c0101b2a:	8b 00                	mov    (%eax),%eax
c0101b2c:	eb 05                	jmp    c0101b33 <ide_device_size+0x33>
    }
    return 0;
c0101b2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b33:	c9                   	leave  
c0101b34:	c3                   	ret    

c0101b35 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101b35:	55                   	push   %ebp
c0101b36:	89 e5                	mov    %esp,%ebp
c0101b38:	57                   	push   %edi
c0101b39:	53                   	push   %ebx
c0101b3a:	83 ec 40             	sub    $0x40,%esp
c0101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b40:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101b44:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101b4b:	77 1a                	ja     c0101b67 <ide_read_secs+0x32>
c0101b4d:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101b52:	77 13                	ja     c0101b67 <ide_read_secs+0x32>
c0101b54:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b58:	6b c0 38             	imul   $0x38,%eax,%eax
c0101b5b:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101b60:	0f b6 00             	movzbl (%eax),%eax
c0101b63:	84 c0                	test   %al,%al
c0101b65:	75 19                	jne    c0101b80 <ide_read_secs+0x4b>
c0101b67:	68 7c b8 10 c0       	push   $0xc010b87c
c0101b6c:	68 37 b8 10 c0       	push   $0xc010b837
c0101b71:	68 9f 00 00 00       	push   $0x9f
c0101b76:	68 4c b8 10 c0       	push   $0xc010b84c
c0101b7b:	e8 06 f2 ff ff       	call   c0100d86 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101b80:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101b87:	77 0f                	ja     c0101b98 <ide_read_secs+0x63>
c0101b89:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101b8c:	8b 45 14             	mov    0x14(%ebp),%eax
c0101b8f:	01 d0                	add    %edx,%eax
c0101b91:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101b96:	76 19                	jbe    c0101bb1 <ide_read_secs+0x7c>
c0101b98:	68 a4 b8 10 c0       	push   $0xc010b8a4
c0101b9d:	68 37 b8 10 c0       	push   $0xc010b837
c0101ba2:	68 a0 00 00 00       	push   $0xa0
c0101ba7:	68 4c b8 10 c0       	push   $0xc010b84c
c0101bac:	e8 d5 f1 ff ff       	call   c0100d86 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101bb1:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bb5:	66 d1 e8             	shr    %ax
c0101bb8:	0f b7 c0             	movzwl %ax,%eax
c0101bbb:	0f b7 04 85 ec b7 10 	movzwl -0x3fef4814(,%eax,4),%eax
c0101bc2:	c0 
c0101bc3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101bc7:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bcb:	66 d1 e8             	shr    %ax
c0101bce:	0f b7 c0             	movzwl %ax,%eax
c0101bd1:	0f b7 04 85 ee b7 10 	movzwl -0x3fef4812(,%eax,4),%eax
c0101bd8:	c0 
c0101bd9:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101bdd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101be1:	83 ec 08             	sub    $0x8,%esp
c0101be4:	6a 00                	push   $0x0
c0101be6:	50                   	push   %eax
c0101be7:	e8 d7 fb ff ff       	call   c01017c3 <ide_wait_ready>
c0101bec:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101bef:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101bf3:	83 c0 02             	add    $0x2,%eax
c0101bf6:	0f b7 c0             	movzwl %ax,%eax
c0101bf9:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101bfd:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c01:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c05:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c09:	ee                   	out    %al,(%dx)
}
c0101c0a:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101c0b:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c0e:	0f b6 c0             	movzbl %al,%eax
c0101c11:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c15:	83 c2 02             	add    $0x2,%edx
c0101c18:	0f b7 d2             	movzwl %dx,%edx
c0101c1b:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c1f:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c22:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c26:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c2a:	ee                   	out    %al,(%dx)
}
c0101c2b:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c2f:	0f b6 c0             	movzbl %al,%eax
c0101c32:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c36:	83 c2 03             	add    $0x3,%edx
c0101c39:	0f b7 d2             	movzwl %dx,%edx
c0101c3c:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c40:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c43:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c47:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c4b:	ee                   	out    %al,(%dx)
}
c0101c4c:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c50:	c1 e8 08             	shr    $0x8,%eax
c0101c53:	0f b6 c0             	movzbl %al,%eax
c0101c56:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c5a:	83 c2 04             	add    $0x4,%edx
c0101c5d:	0f b7 d2             	movzwl %dx,%edx
c0101c60:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c64:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c67:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101c6b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101c6f:	ee                   	out    %al,(%dx)
}
c0101c70:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101c71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c74:	c1 e8 10             	shr    $0x10,%eax
c0101c77:	0f b6 c0             	movzbl %al,%eax
c0101c7a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c7e:	83 c2 05             	add    $0x5,%edx
c0101c81:	0f b7 d2             	movzwl %dx,%edx
c0101c84:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101c88:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c8b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101c8f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101c93:	ee                   	out    %al,(%dx)
}
c0101c94:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101c95:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c99:	c1 e0 04             	shl    $0x4,%eax
c0101c9c:	83 e0 10             	and    $0x10,%eax
c0101c9f:	89 c2                	mov    %eax,%edx
c0101ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ca4:	c1 e8 18             	shr    $0x18,%eax
c0101ca7:	83 e0 0f             	and    $0xf,%eax
c0101caa:	09 d0                	or     %edx,%eax
c0101cac:	83 c8 e0             	or     $0xffffffe0,%eax
c0101caf:	0f b6 c0             	movzbl %al,%eax
c0101cb2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cb6:	83 c2 06             	add    $0x6,%edx
c0101cb9:	0f b7 d2             	movzwl %dx,%edx
c0101cbc:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cc0:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cc3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101cc7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101ccb:	ee                   	out    %al,(%dx)
}
c0101ccc:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101ccd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cd1:	83 c0 07             	add    $0x7,%eax
c0101cd4:	0f b7 c0             	movzwl %ax,%eax
c0101cd7:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101cdb:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cdf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101ce3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101ce7:	ee                   	out    %al,(%dx)
}
c0101ce8:	90                   	nop

    int ret = 0;
c0101ce9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101cf0:	eb 57                	jmp    c0101d49 <ide_read_secs+0x214>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101cf2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cf6:	83 ec 08             	sub    $0x8,%esp
c0101cf9:	6a 01                	push   $0x1
c0101cfb:	50                   	push   %eax
c0101cfc:	e8 c2 fa ff ff       	call   c01017c3 <ide_wait_ready>
c0101d01:	83 c4 10             	add    $0x10,%esp
c0101d04:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d0b:	75 44                	jne    c0101d51 <ide_read_secs+0x21c>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d0d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d11:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101d14:	8b 45 10             	mov    0x10(%ebp),%eax
c0101d17:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101d1a:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101d21:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101d24:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101d27:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101d2a:	89 cb                	mov    %ecx,%ebx
c0101d2c:	89 df                	mov    %ebx,%edi
c0101d2e:	89 c1                	mov    %eax,%ecx
c0101d30:	fc                   	cld    
c0101d31:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101d33:	89 c8                	mov    %ecx,%eax
c0101d35:	89 fb                	mov    %edi,%ebx
c0101d37:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101d3a:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101d3d:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d3e:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101d42:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101d49:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d4d:	75 a3                	jne    c0101cf2 <ide_read_secs+0x1bd>
    }

out:
c0101d4f:	eb 01                	jmp    c0101d52 <ide_read_secs+0x21d>
            goto out;
c0101d51:	90                   	nop
    return ret;
c0101d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d55:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101d58:	5b                   	pop    %ebx
c0101d59:	5f                   	pop    %edi
c0101d5a:	5d                   	pop    %ebp
c0101d5b:	c3                   	ret    

c0101d5c <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d5c:	55                   	push   %ebp
c0101d5d:	89 e5                	mov    %esp,%ebp
c0101d5f:	56                   	push   %esi
c0101d60:	53                   	push   %ebx
c0101d61:	83 ec 40             	sub    $0x40,%esp
c0101d64:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d67:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101d6b:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101d72:	77 1a                	ja     c0101d8e <ide_write_secs+0x32>
c0101d74:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101d79:	77 13                	ja     c0101d8e <ide_write_secs+0x32>
c0101d7b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d7f:	6b c0 38             	imul   $0x38,%eax,%eax
c0101d82:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101d87:	0f b6 00             	movzbl (%eax),%eax
c0101d8a:	84 c0                	test   %al,%al
c0101d8c:	75 19                	jne    c0101da7 <ide_write_secs+0x4b>
c0101d8e:	68 7c b8 10 c0       	push   $0xc010b87c
c0101d93:	68 37 b8 10 c0       	push   $0xc010b837
c0101d98:	68 bc 00 00 00       	push   $0xbc
c0101d9d:	68 4c b8 10 c0       	push   $0xc010b84c
c0101da2:	e8 df ef ff ff       	call   c0100d86 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101da7:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101dae:	77 0f                	ja     c0101dbf <ide_write_secs+0x63>
c0101db0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101db3:	8b 45 14             	mov    0x14(%ebp),%eax
c0101db6:	01 d0                	add    %edx,%eax
c0101db8:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101dbd:	76 19                	jbe    c0101dd8 <ide_write_secs+0x7c>
c0101dbf:	68 a4 b8 10 c0       	push   $0xc010b8a4
c0101dc4:	68 37 b8 10 c0       	push   $0xc010b837
c0101dc9:	68 bd 00 00 00       	push   $0xbd
c0101dce:	68 4c b8 10 c0       	push   $0xc010b84c
c0101dd3:	e8 ae ef ff ff       	call   c0100d86 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101dd8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ddc:	66 d1 e8             	shr    %ax
c0101ddf:	0f b7 c0             	movzwl %ax,%eax
c0101de2:	0f b7 04 85 ec b7 10 	movzwl -0x3fef4814(,%eax,4),%eax
c0101de9:	c0 
c0101dea:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101dee:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101df2:	66 d1 e8             	shr    %ax
c0101df5:	0f b7 c0             	movzwl %ax,%eax
c0101df8:	0f b7 04 85 ee b7 10 	movzwl -0x3fef4812(,%eax,4),%eax
c0101dff:	c0 
c0101e00:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101e04:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e08:	83 ec 08             	sub    $0x8,%esp
c0101e0b:	6a 00                	push   $0x0
c0101e0d:	50                   	push   %eax
c0101e0e:	e8 b0 f9 ff ff       	call   c01017c3 <ide_wait_ready>
c0101e13:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101e16:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101e1a:	83 c0 02             	add    $0x2,%eax
c0101e1d:	0f b7 c0             	movzwl %ax,%eax
c0101e20:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101e24:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e28:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101e2c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101e30:	ee                   	out    %al,(%dx)
}
c0101e31:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101e32:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e35:	0f b6 c0             	movzbl %al,%eax
c0101e38:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e3c:	83 c2 02             	add    $0x2,%edx
c0101e3f:	0f b7 d2             	movzwl %dx,%edx
c0101e42:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101e46:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e49:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101e4d:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101e51:	ee                   	out    %al,(%dx)
}
c0101e52:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101e53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e56:	0f b6 c0             	movzbl %al,%eax
c0101e59:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e5d:	83 c2 03             	add    $0x3,%edx
c0101e60:	0f b7 d2             	movzwl %dx,%edx
c0101e63:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101e67:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e6a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101e6e:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101e72:	ee                   	out    %al,(%dx)
}
c0101e73:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101e74:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e77:	c1 e8 08             	shr    $0x8,%eax
c0101e7a:	0f b6 c0             	movzbl %al,%eax
c0101e7d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e81:	83 c2 04             	add    $0x4,%edx
c0101e84:	0f b7 d2             	movzwl %dx,%edx
c0101e87:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101e8b:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e8e:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101e92:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101e96:	ee                   	out    %al,(%dx)
}
c0101e97:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101e98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e9b:	c1 e8 10             	shr    $0x10,%eax
c0101e9e:	0f b6 c0             	movzbl %al,%eax
c0101ea1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ea5:	83 c2 05             	add    $0x5,%edx
c0101ea8:	0f b7 d2             	movzwl %dx,%edx
c0101eab:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101eaf:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101eb2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101eb6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101eba:	ee                   	out    %al,(%dx)
}
c0101ebb:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101ebc:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ec0:	c1 e0 04             	shl    $0x4,%eax
c0101ec3:	83 e0 10             	and    $0x10,%eax
c0101ec6:	89 c2                	mov    %eax,%edx
c0101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ecb:	c1 e8 18             	shr    $0x18,%eax
c0101ece:	83 e0 0f             	and    $0xf,%eax
c0101ed1:	09 d0                	or     %edx,%eax
c0101ed3:	83 c8 e0             	or     $0xffffffe0,%eax
c0101ed6:	0f b6 c0             	movzbl %al,%eax
c0101ed9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101edd:	83 c2 06             	add    $0x6,%edx
c0101ee0:	0f b7 d2             	movzwl %dx,%edx
c0101ee3:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ee7:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101eea:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101eee:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101ef2:	ee                   	out    %al,(%dx)
}
c0101ef3:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101ef4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ef8:	83 c0 07             	add    $0x7,%eax
c0101efb:	0f b7 c0             	movzwl %ax,%eax
c0101efe:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101f02:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f06:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f0a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f0e:	ee                   	out    %al,(%dx)
}
c0101f0f:	90                   	nop

    int ret = 0;
c0101f10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f17:	eb 57                	jmp    c0101f70 <ide_write_secs+0x214>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101f19:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f1d:	83 ec 08             	sub    $0x8,%esp
c0101f20:	6a 01                	push   $0x1
c0101f22:	50                   	push   %eax
c0101f23:	e8 9b f8 ff ff       	call   c01017c3 <ide_wait_ready>
c0101f28:	83 c4 10             	add    $0x10,%esp
c0101f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101f2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f32:	75 44                	jne    c0101f78 <ide_write_secs+0x21c>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f34:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f38:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f3b:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f3e:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f41:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101f48:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f4b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101f4e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101f51:	89 cb                	mov    %ecx,%ebx
c0101f53:	89 de                	mov    %ebx,%esi
c0101f55:	89 c1                	mov    %eax,%ecx
c0101f57:	fc                   	cld    
c0101f58:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101f5a:	89 c8                	mov    %ecx,%eax
c0101f5c:	89 f3                	mov    %esi,%ebx
c0101f5e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101f61:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101f64:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f65:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101f69:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101f70:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101f74:	75 a3                	jne    c0101f19 <ide_write_secs+0x1bd>
    }

out:
c0101f76:	eb 01                	jmp    c0101f79 <ide_write_secs+0x21d>
            goto out;
c0101f78:	90                   	nop
    return ret;
c0101f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101f7f:	5b                   	pop    %ebx
c0101f80:	5e                   	pop    %esi
c0101f81:	5d                   	pop    %ebp
c0101f82:	c3                   	ret    

c0101f83 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101f83:	55                   	push   %ebp
c0101f84:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101f86:	fb                   	sti    
}
c0101f87:	90                   	nop
    sti();
}
c0101f88:	90                   	nop
c0101f89:	5d                   	pop    %ebp
c0101f8a:	c3                   	ret    

c0101f8b <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101f8b:	55                   	push   %ebp
c0101f8c:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101f8e:	fa                   	cli    
}
c0101f8f:	90                   	nop
    cli();
}
c0101f90:	90                   	nop
c0101f91:	5d                   	pop    %ebp
c0101f92:	c3                   	ret    

c0101f93 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f93:	55                   	push   %ebp
c0101f94:	89 e5                	mov    %esp,%ebp
c0101f96:	83 ec 14             	sub    $0x14,%esp
c0101f99:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f9c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101fa0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101fa4:	66 a3 50 f5 12 c0    	mov    %ax,0xc012f550
    if (did_init) {
c0101faa:	a1 60 37 1a c0       	mov    0xc01a3760,%eax
c0101faf:	85 c0                	test   %eax,%eax
c0101fb1:	74 38                	je     c0101feb <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0101fb3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101fb7:	0f b6 c0             	movzbl %al,%eax
c0101fba:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101fc0:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fc3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101fc7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101fcb:	ee                   	out    %al,(%dx)
}
c0101fcc:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101fcd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101fd1:	66 c1 e8 08          	shr    $0x8,%ax
c0101fd5:	0f b6 c0             	movzbl %al,%eax
c0101fd8:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101fde:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fe1:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101fe5:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101fe9:	ee                   	out    %al,(%dx)
}
c0101fea:	90                   	nop
    }
}
c0101feb:	90                   	nop
c0101fec:	c9                   	leave  
c0101fed:	c3                   	ret    

c0101fee <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101fee:	55                   	push   %ebp
c0101fef:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c0101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ff4:	ba 01 00 00 00       	mov    $0x1,%edx
c0101ff9:	89 c1                	mov    %eax,%ecx
c0101ffb:	d3 e2                	shl    %cl,%edx
c0101ffd:	89 d0                	mov    %edx,%eax
c0101fff:	f7 d0                	not    %eax
c0102001:	89 c2                	mov    %eax,%edx
c0102003:	0f b7 05 50 f5 12 c0 	movzwl 0xc012f550,%eax
c010200a:	21 d0                	and    %edx,%eax
c010200c:	0f b7 c0             	movzwl %ax,%eax
c010200f:	50                   	push   %eax
c0102010:	e8 7e ff ff ff       	call   c0101f93 <pic_setmask>
c0102015:	83 c4 04             	add    $0x4,%esp
}
c0102018:	90                   	nop
c0102019:	c9                   	leave  
c010201a:	c3                   	ret    

c010201b <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010201b:	55                   	push   %ebp
c010201c:	89 e5                	mov    %esp,%ebp
c010201e:	83 ec 40             	sub    $0x40,%esp
    did_init = 1;
c0102021:	c7 05 60 37 1a c0 01 	movl   $0x1,0xc01a3760
c0102028:	00 00 00 
c010202b:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0102031:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102035:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102039:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010203d:	ee                   	out    %al,(%dx)
}
c010203e:	90                   	nop
c010203f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0102045:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102049:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010204d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102051:	ee                   	out    %al,(%dx)
}
c0102052:	90                   	nop
c0102053:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0102059:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010205d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102061:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0102065:	ee                   	out    %al,(%dx)
}
c0102066:	90                   	nop
c0102067:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010206d:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102071:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102075:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102079:	ee                   	out    %al,(%dx)
}
c010207a:	90                   	nop
c010207b:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0102081:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102085:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102089:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010208d:	ee                   	out    %al,(%dx)
}
c010208e:	90                   	nop
c010208f:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c0102095:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102099:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010209d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01020a1:	ee                   	out    %al,(%dx)
}
c01020a2:	90                   	nop
c01020a3:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01020a9:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020ad:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01020b1:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01020b5:	ee                   	out    %al,(%dx)
}
c01020b6:	90                   	nop
c01020b7:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01020bd:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020c1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01020c5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01020c9:	ee                   	out    %al,(%dx)
}
c01020ca:	90                   	nop
c01020cb:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01020d1:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020d5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01020d9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01020dd:	ee                   	out    %al,(%dx)
}
c01020de:	90                   	nop
c01020df:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01020e5:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020e9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01020ed:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01020f1:	ee                   	out    %al,(%dx)
}
c01020f2:	90                   	nop
c01020f3:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01020f9:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020fd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102101:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102105:	ee                   	out    %al,(%dx)
}
c0102106:	90                   	nop
c0102107:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010210d:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102111:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102115:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102119:	ee                   	out    %al,(%dx)
}
c010211a:	90                   	nop
c010211b:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0102121:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102125:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102129:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010212d:	ee                   	out    %al,(%dx)
}
c010212e:	90                   	nop
c010212f:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0102135:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102139:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010213d:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102141:	ee                   	out    %al,(%dx)
}
c0102142:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102143:	0f b7 05 50 f5 12 c0 	movzwl 0xc012f550,%eax
c010214a:	66 83 f8 ff          	cmp    $0xffff,%ax
c010214e:	74 13                	je     c0102163 <pic_init+0x148>
        pic_setmask(irq_mask);
c0102150:	0f b7 05 50 f5 12 c0 	movzwl 0xc012f550,%eax
c0102157:	0f b7 c0             	movzwl %ax,%eax
c010215a:	50                   	push   %eax
c010215b:	e8 33 fe ff ff       	call   c0101f93 <pic_setmask>
c0102160:	83 c4 04             	add    $0x4,%esp
    }
}
c0102163:	90                   	nop
c0102164:	c9                   	leave  
c0102165:	c3                   	ret    

c0102166 <print_ticks>:
#include <x86.h>

#define TICK_NUM 100

static void
print_ticks() {
c0102166:	55                   	push   %ebp
c0102167:	89 e5                	mov    %esp,%ebp
c0102169:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n", TICK_NUM);
c010216c:	83 ec 08             	sub    $0x8,%esp
c010216f:	6a 64                	push   $0x64
c0102171:	68 e0 b8 10 c0       	push   $0xc010b8e0
c0102176:	e8 cd e1 ff ff       	call   c0100348 <cprintf>
c010217b:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010217e:	90                   	nop
c010217f:	c9                   	leave  
c0102180:	c3                   	ret    

c0102181 <idt_init>:
static struct pseudodesc idt_pd = {
    sizeof(idt) - 1, (uintptr_t)idt};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102181:	55                   	push   %ebp
c0102182:	89 e5                	mov    %esp,%ebp
c0102184:	83 ec 10             	sub    $0x10,%esp
    /* LAB5 YOUR CODE */
    //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
    //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++) {
c0102187:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010218e:	e9 c3 00 00 00       	jmp    c0102256 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102193:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102196:	8b 04 85 e0 f5 12 c0 	mov    -0x3fed0a20(,%eax,4),%eax
c010219d:	89 c2                	mov    %eax,%edx
c010219f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021a2:	66 89 14 c5 80 37 1a 	mov    %dx,-0x3fe5c880(,%eax,8)
c01021a9:	c0 
c01021aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ad:	66 c7 04 c5 82 37 1a 	movw   $0x8,-0x3fe5c87e(,%eax,8)
c01021b4:	c0 08 00 
c01021b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ba:	0f b6 14 c5 84 37 1a 	movzbl -0x3fe5c87c(,%eax,8),%edx
c01021c1:	c0 
c01021c2:	83 e2 e0             	and    $0xffffffe0,%edx
c01021c5:	88 14 c5 84 37 1a c0 	mov    %dl,-0x3fe5c87c(,%eax,8)
c01021cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021cf:	0f b6 14 c5 84 37 1a 	movzbl -0x3fe5c87c(,%eax,8),%edx
c01021d6:	c0 
c01021d7:	83 e2 1f             	and    $0x1f,%edx
c01021da:	88 14 c5 84 37 1a c0 	mov    %dl,-0x3fe5c87c(,%eax,8)
c01021e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021e4:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c01021eb:	c0 
c01021ec:	83 e2 f0             	and    $0xfffffff0,%edx
c01021ef:	83 ca 0e             	or     $0xe,%edx
c01021f2:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c01021f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021fc:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c0102203:	c0 
c0102204:	83 e2 ef             	and    $0xffffffef,%edx
c0102207:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c010220e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102211:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c0102218:	c0 
c0102219:	83 e2 9f             	and    $0xffffff9f,%edx
c010221c:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c0102223:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102226:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c010222d:	c0 
c010222e:	83 ca 80             	or     $0xffffff80,%edx
c0102231:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c0102238:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010223b:	8b 04 85 e0 f5 12 c0 	mov    -0x3fed0a20(,%eax,4),%eax
c0102242:	c1 e8 10             	shr    $0x10,%eax
c0102245:	89 c2                	mov    %eax,%edx
c0102247:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010224a:	66 89 14 c5 86 37 1a 	mov    %dx,-0x3fe5c87a(,%eax,8)
c0102251:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++) {
c0102252:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102256:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102259:	3d ff 00 00 00       	cmp    $0xff,%eax
c010225e:	0f 86 2f ff ff ff    	jbe    c0102193 <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0102264:	a1 c4 f7 12 c0       	mov    0xc012f7c4,%eax
c0102269:	66 a3 48 3b 1a c0    	mov    %ax,0xc01a3b48
c010226f:	66 c7 05 4a 3b 1a c0 	movw   $0x8,0xc01a3b4a
c0102276:	08 00 
c0102278:	0f b6 05 4c 3b 1a c0 	movzbl 0xc01a3b4c,%eax
c010227f:	83 e0 e0             	and    $0xffffffe0,%eax
c0102282:	a2 4c 3b 1a c0       	mov    %al,0xc01a3b4c
c0102287:	0f b6 05 4c 3b 1a c0 	movzbl 0xc01a3b4c,%eax
c010228e:	83 e0 1f             	and    $0x1f,%eax
c0102291:	a2 4c 3b 1a c0       	mov    %al,0xc01a3b4c
c0102296:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c010229d:	83 e0 f0             	and    $0xfffffff0,%eax
c01022a0:	83 c8 0e             	or     $0xe,%eax
c01022a3:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01022a8:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c01022af:	83 e0 ef             	and    $0xffffffef,%eax
c01022b2:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01022b7:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c01022be:	83 c8 60             	or     $0x60,%eax
c01022c1:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01022c6:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c01022cd:	83 c8 80             	or     $0xffffff80,%eax
c01022d0:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01022d5:	a1 c4 f7 12 c0       	mov    0xc012f7c4,%eax
c01022da:	c1 e8 10             	shr    $0x10,%eax
c01022dd:	66 a3 4e 3b 1a c0    	mov    %ax,0xc01a3b4e
    SETGATE(idt[SYS_CALL], 0, GD_KTEXT, __vectors[SYS_CALL], DPL_USER);
c01022e3:	a1 e0 f7 12 c0       	mov    0xc012f7e0,%eax
c01022e8:	66 a3 80 3b 1a c0    	mov    %ax,0xc01a3b80
c01022ee:	66 c7 05 82 3b 1a c0 	movw   $0x8,0xc01a3b82
c01022f5:	08 00 
c01022f7:	0f b6 05 84 3b 1a c0 	movzbl 0xc01a3b84,%eax
c01022fe:	83 e0 e0             	and    $0xffffffe0,%eax
c0102301:	a2 84 3b 1a c0       	mov    %al,0xc01a3b84
c0102306:	0f b6 05 84 3b 1a c0 	movzbl 0xc01a3b84,%eax
c010230d:	83 e0 1f             	and    $0x1f,%eax
c0102310:	a2 84 3b 1a c0       	mov    %al,0xc01a3b84
c0102315:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c010231c:	83 e0 f0             	and    $0xfffffff0,%eax
c010231f:	83 c8 0e             	or     $0xe,%eax
c0102322:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102327:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c010232e:	83 e0 ef             	and    $0xffffffef,%eax
c0102331:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102336:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c010233d:	83 c8 60             	or     $0x60,%eax
c0102340:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102345:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c010234c:	83 c8 80             	or     $0xffffff80,%eax
c010234f:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102354:	a1 e0 f7 12 c0       	mov    0xc012f7e0,%eax
c0102359:	c1 e8 10             	shr    $0x10,%eax
c010235c:	66 a3 86 3b 1a c0    	mov    %ax,0xc01a3b86
c0102362:	c7 45 f8 60 f5 12 c0 	movl   $0xc012f560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102369:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010236c:	0f 01 18             	lidtl  (%eax)
}
c010236f:	90                   	nop
    lidt(&idt_pd);
}
c0102370:	90                   	nop
c0102371:	c9                   	leave  
c0102372:	c3                   	ret    

c0102373 <trapname>:

static const char *
trapname(int trapno) {
c0102373:	55                   	push   %ebp
c0102374:	89 e5                	mov    %esp,%ebp
        "x87 FPU Floating-Point Error",
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"};

    if (trapno < sizeof(excnames) / sizeof(const char *const)) {
c0102376:	8b 45 08             	mov    0x8(%ebp),%eax
c0102379:	83 f8 13             	cmp    $0x13,%eax
c010237c:	77 0c                	ja     c010238a <trapname+0x17>
        return excnames[trapno];
c010237e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102381:	8b 04 85 e0 bd 10 c0 	mov    -0x3fef4220(,%eax,4),%eax
c0102388:	eb 18                	jmp    c01023a2 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010238a:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c010238e:	7e 0d                	jle    c010239d <trapname+0x2a>
c0102390:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102394:	7f 07                	jg     c010239d <trapname+0x2a>
        return "Hardware Interrupt";
c0102396:	b8 ea b8 10 c0       	mov    $0xc010b8ea,%eax
c010239b:	eb 05                	jmp    c01023a2 <trapname+0x2f>
    }
    return "(unknown trap)";
c010239d:	b8 fd b8 10 c0       	mov    $0xc010b8fd,%eax
}
c01023a2:	5d                   	pop    %ebp
c01023a3:	c3                   	ret    

c01023a4 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023a4:	55                   	push   %ebp
c01023a5:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023aa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023ae:	66 83 f8 08          	cmp    $0x8,%ax
c01023b2:	0f 94 c0             	sete   %al
c01023b5:	0f b6 c0             	movzbl %al,%eax
}
c01023b8:	5d                   	pop    %ebp
c01023b9:	c3                   	ret    

c01023ba <print_trapframe>:
    NULL,
    NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023ba:	55                   	push   %ebp
c01023bb:	89 e5                	mov    %esp,%ebp
c01023bd:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c01023c0:	83 ec 08             	sub    $0x8,%esp
c01023c3:	ff 75 08             	pushl  0x8(%ebp)
c01023c6:	68 3e b9 10 c0       	push   $0xc010b93e
c01023cb:	e8 78 df ff ff       	call   c0100348 <cprintf>
c01023d0:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c01023d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d6:	83 ec 0c             	sub    $0xc,%esp
c01023d9:	50                   	push   %eax
c01023da:	e8 b4 01 00 00       	call   c0102593 <print_regs>
c01023df:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01023e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e5:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01023e9:	0f b7 c0             	movzwl %ax,%eax
c01023ec:	83 ec 08             	sub    $0x8,%esp
c01023ef:	50                   	push   %eax
c01023f0:	68 4f b9 10 c0       	push   $0xc010b94f
c01023f5:	e8 4e df ff ff       	call   c0100348 <cprintf>
c01023fa:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01023fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102400:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102404:	0f b7 c0             	movzwl %ax,%eax
c0102407:	83 ec 08             	sub    $0x8,%esp
c010240a:	50                   	push   %eax
c010240b:	68 62 b9 10 c0       	push   $0xc010b962
c0102410:	e8 33 df ff ff       	call   c0100348 <cprintf>
c0102415:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102418:	8b 45 08             	mov    0x8(%ebp),%eax
c010241b:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010241f:	0f b7 c0             	movzwl %ax,%eax
c0102422:	83 ec 08             	sub    $0x8,%esp
c0102425:	50                   	push   %eax
c0102426:	68 75 b9 10 c0       	push   $0xc010b975
c010242b:	e8 18 df ff ff       	call   c0100348 <cprintf>
c0102430:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102433:	8b 45 08             	mov    0x8(%ebp),%eax
c0102436:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010243a:	0f b7 c0             	movzwl %ax,%eax
c010243d:	83 ec 08             	sub    $0x8,%esp
c0102440:	50                   	push   %eax
c0102441:	68 88 b9 10 c0       	push   $0xc010b988
c0102446:	e8 fd de ff ff       	call   c0100348 <cprintf>
c010244b:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010244e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102451:	8b 40 30             	mov    0x30(%eax),%eax
c0102454:	83 ec 0c             	sub    $0xc,%esp
c0102457:	50                   	push   %eax
c0102458:	e8 16 ff ff ff       	call   c0102373 <trapname>
c010245d:	83 c4 10             	add    $0x10,%esp
c0102460:	8b 55 08             	mov    0x8(%ebp),%edx
c0102463:	8b 52 30             	mov    0x30(%edx),%edx
c0102466:	83 ec 04             	sub    $0x4,%esp
c0102469:	50                   	push   %eax
c010246a:	52                   	push   %edx
c010246b:	68 9b b9 10 c0       	push   $0xc010b99b
c0102470:	e8 d3 de ff ff       	call   c0100348 <cprintf>
c0102475:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102478:	8b 45 08             	mov    0x8(%ebp),%eax
c010247b:	8b 40 34             	mov    0x34(%eax),%eax
c010247e:	83 ec 08             	sub    $0x8,%esp
c0102481:	50                   	push   %eax
c0102482:	68 ad b9 10 c0       	push   $0xc010b9ad
c0102487:	e8 bc de ff ff       	call   c0100348 <cprintf>
c010248c:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010248f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102492:	8b 40 38             	mov    0x38(%eax),%eax
c0102495:	83 ec 08             	sub    $0x8,%esp
c0102498:	50                   	push   %eax
c0102499:	68 bc b9 10 c0       	push   $0xc010b9bc
c010249e:	e8 a5 de ff ff       	call   c0100348 <cprintf>
c01024a3:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024ad:	0f b7 c0             	movzwl %ax,%eax
c01024b0:	83 ec 08             	sub    $0x8,%esp
c01024b3:	50                   	push   %eax
c01024b4:	68 cb b9 10 c0       	push   $0xc010b9cb
c01024b9:	e8 8a de ff ff       	call   c0100348 <cprintf>
c01024be:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c4:	8b 40 40             	mov    0x40(%eax),%eax
c01024c7:	83 ec 08             	sub    $0x8,%esp
c01024ca:	50                   	push   %eax
c01024cb:	68 de b9 10 c0       	push   $0xc010b9de
c01024d0:	e8 73 de ff ff       	call   c0100348 <cprintf>
c01024d5:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1) {
c01024d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01024df:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01024e6:	eb 3f                	jmp    c0102527 <print_trapframe+0x16d>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01024e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024eb:	8b 50 40             	mov    0x40(%eax),%edx
c01024ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01024f1:	21 d0                	and    %edx,%eax
c01024f3:	85 c0                	test   %eax,%eax
c01024f5:	74 29                	je     c0102520 <print_trapframe+0x166>
c01024f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024fa:	8b 04 85 80 f5 12 c0 	mov    -0x3fed0a80(,%eax,4),%eax
c0102501:	85 c0                	test   %eax,%eax
c0102503:	74 1b                	je     c0102520 <print_trapframe+0x166>
            cprintf("%s,", IA32flags[i]);
c0102505:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102508:	8b 04 85 80 f5 12 c0 	mov    -0x3fed0a80(,%eax,4),%eax
c010250f:	83 ec 08             	sub    $0x8,%esp
c0102512:	50                   	push   %eax
c0102513:	68 ed b9 10 c0       	push   $0xc010b9ed
c0102518:	e8 2b de ff ff       	call   c0100348 <cprintf>
c010251d:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1) {
c0102520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102524:	d1 65 f0             	shll   -0x10(%ebp)
c0102527:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010252a:	83 f8 17             	cmp    $0x17,%eax
c010252d:	76 b9                	jbe    c01024e8 <print_trapframe+0x12e>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010252f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102532:	8b 40 40             	mov    0x40(%eax),%eax
c0102535:	c1 e8 0c             	shr    $0xc,%eax
c0102538:	83 e0 03             	and    $0x3,%eax
c010253b:	83 ec 08             	sub    $0x8,%esp
c010253e:	50                   	push   %eax
c010253f:	68 f1 b9 10 c0       	push   $0xc010b9f1
c0102544:	e8 ff dd ff ff       	call   c0100348 <cprintf>
c0102549:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c010254c:	83 ec 0c             	sub    $0xc,%esp
c010254f:	ff 75 08             	pushl  0x8(%ebp)
c0102552:	e8 4d fe ff ff       	call   c01023a4 <trap_in_kernel>
c0102557:	83 c4 10             	add    $0x10,%esp
c010255a:	85 c0                	test   %eax,%eax
c010255c:	75 32                	jne    c0102590 <print_trapframe+0x1d6>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010255e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102561:	8b 40 44             	mov    0x44(%eax),%eax
c0102564:	83 ec 08             	sub    $0x8,%esp
c0102567:	50                   	push   %eax
c0102568:	68 fa b9 10 c0       	push   $0xc010b9fa
c010256d:	e8 d6 dd ff ff       	call   c0100348 <cprintf>
c0102572:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102575:	8b 45 08             	mov    0x8(%ebp),%eax
c0102578:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010257c:	0f b7 c0             	movzwl %ax,%eax
c010257f:	83 ec 08             	sub    $0x8,%esp
c0102582:	50                   	push   %eax
c0102583:	68 09 ba 10 c0       	push   $0xc010ba09
c0102588:	e8 bb dd ff ff       	call   c0100348 <cprintf>
c010258d:	83 c4 10             	add    $0x10,%esp
    }
}
c0102590:	90                   	nop
c0102591:	c9                   	leave  
c0102592:	c3                   	ret    

c0102593 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102593:	55                   	push   %ebp
c0102594:	89 e5                	mov    %esp,%ebp
c0102596:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102599:	8b 45 08             	mov    0x8(%ebp),%eax
c010259c:	8b 00                	mov    (%eax),%eax
c010259e:	83 ec 08             	sub    $0x8,%esp
c01025a1:	50                   	push   %eax
c01025a2:	68 1c ba 10 c0       	push   $0xc010ba1c
c01025a7:	e8 9c dd ff ff       	call   c0100348 <cprintf>
c01025ac:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025af:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b2:	8b 40 04             	mov    0x4(%eax),%eax
c01025b5:	83 ec 08             	sub    $0x8,%esp
c01025b8:	50                   	push   %eax
c01025b9:	68 2b ba 10 c0       	push   $0xc010ba2b
c01025be:	e8 85 dd ff ff       	call   c0100348 <cprintf>
c01025c3:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01025c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01025c9:	8b 40 08             	mov    0x8(%eax),%eax
c01025cc:	83 ec 08             	sub    $0x8,%esp
c01025cf:	50                   	push   %eax
c01025d0:	68 3a ba 10 c0       	push   $0xc010ba3a
c01025d5:	e8 6e dd ff ff       	call   c0100348 <cprintf>
c01025da:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e0:	8b 40 0c             	mov    0xc(%eax),%eax
c01025e3:	83 ec 08             	sub    $0x8,%esp
c01025e6:	50                   	push   %eax
c01025e7:	68 49 ba 10 c0       	push   $0xc010ba49
c01025ec:	e8 57 dd ff ff       	call   c0100348 <cprintf>
c01025f1:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01025f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f7:	8b 40 10             	mov    0x10(%eax),%eax
c01025fa:	83 ec 08             	sub    $0x8,%esp
c01025fd:	50                   	push   %eax
c01025fe:	68 58 ba 10 c0       	push   $0xc010ba58
c0102603:	e8 40 dd ff ff       	call   c0100348 <cprintf>
c0102608:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010260b:	8b 45 08             	mov    0x8(%ebp),%eax
c010260e:	8b 40 14             	mov    0x14(%eax),%eax
c0102611:	83 ec 08             	sub    $0x8,%esp
c0102614:	50                   	push   %eax
c0102615:	68 67 ba 10 c0       	push   $0xc010ba67
c010261a:	e8 29 dd ff ff       	call   c0100348 <cprintf>
c010261f:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102622:	8b 45 08             	mov    0x8(%ebp),%eax
c0102625:	8b 40 18             	mov    0x18(%eax),%eax
c0102628:	83 ec 08             	sub    $0x8,%esp
c010262b:	50                   	push   %eax
c010262c:	68 76 ba 10 c0       	push   $0xc010ba76
c0102631:	e8 12 dd ff ff       	call   c0100348 <cprintf>
c0102636:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102639:	8b 45 08             	mov    0x8(%ebp),%eax
c010263c:	8b 40 1c             	mov    0x1c(%eax),%eax
c010263f:	83 ec 08             	sub    $0x8,%esp
c0102642:	50                   	push   %eax
c0102643:	68 85 ba 10 c0       	push   $0xc010ba85
c0102648:	e8 fb dc ff ff       	call   c0100348 <cprintf>
c010264d:	83 c4 10             	add    $0x10,%esp
}
c0102650:	90                   	nop
c0102651:	c9                   	leave  
c0102652:	c3                   	ret    

c0102653 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102653:	55                   	push   %ebp
c0102654:	89 e5                	mov    %esp,%ebp
c0102656:	53                   	push   %ebx
c0102657:	83 ec 14             	sub    $0x14,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010265a:	8b 45 08             	mov    0x8(%ebp),%eax
c010265d:	8b 40 34             	mov    0x34(%eax),%eax
c0102660:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102663:	85 c0                	test   %eax,%eax
c0102665:	74 07                	je     c010266e <print_pgfault+0x1b>
c0102667:	bb 94 ba 10 c0       	mov    $0xc010ba94,%ebx
c010266c:	eb 05                	jmp    c0102673 <print_pgfault+0x20>
c010266e:	bb a5 ba 10 c0       	mov    $0xc010baa5,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c0102673:	8b 45 08             	mov    0x8(%ebp),%eax
c0102676:	8b 40 34             	mov    0x34(%eax),%eax
c0102679:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010267c:	85 c0                	test   %eax,%eax
c010267e:	74 07                	je     c0102687 <print_pgfault+0x34>
c0102680:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102685:	eb 05                	jmp    c010268c <print_pgfault+0x39>
c0102687:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c010268c:	8b 45 08             	mov    0x8(%ebp),%eax
c010268f:	8b 40 34             	mov    0x34(%eax),%eax
c0102692:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102695:	85 c0                	test   %eax,%eax
c0102697:	74 07                	je     c01026a0 <print_pgfault+0x4d>
c0102699:	ba 55 00 00 00       	mov    $0x55,%edx
c010269e:	eb 05                	jmp    c01026a5 <print_pgfault+0x52>
c01026a0:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026a5:	0f 20 d0             	mov    %cr2,%eax
c01026a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01026ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01026ae:	83 ec 0c             	sub    $0xc,%esp
c01026b1:	53                   	push   %ebx
c01026b2:	51                   	push   %ecx
c01026b3:	52                   	push   %edx
c01026b4:	50                   	push   %eax
c01026b5:	68 b4 ba 10 c0       	push   $0xc010bab4
c01026ba:	e8 89 dc ff ff       	call   c0100348 <cprintf>
c01026bf:	83 c4 20             	add    $0x20,%esp
}
c01026c2:	90                   	nop
c01026c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01026c6:	c9                   	leave  
c01026c7:	c3                   	ret    

c01026c8 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026c8:	55                   	push   %ebp
c01026c9:	89 e5                	mov    %esp,%ebp
c01026cb:	83 ec 18             	sub    $0x18,%esp
    extern struct mm_struct *check_mm_struct;
    if (check_mm_struct != NULL) {  //used for test check_swap
c01026ce:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c01026d3:	85 c0                	test   %eax,%eax
c01026d5:	74 0e                	je     c01026e5 <pgfault_handler+0x1d>
        print_pgfault(tf);
c01026d7:	83 ec 0c             	sub    $0xc,%esp
c01026da:	ff 75 08             	pushl  0x8(%ebp)
c01026dd:	e8 71 ff ff ff       	call   c0102653 <print_pgfault>
c01026e2:	83 c4 10             	add    $0x10,%esp
    }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c01026e5:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c01026ea:	85 c0                	test   %eax,%eax
c01026ec:	74 32                	je     c0102720 <pgfault_handler+0x58>
        assert(current == idleproc);
c01026ee:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c01026f4:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c01026f9:	39 c2                	cmp    %eax,%edx
c01026fb:	74 19                	je     c0102716 <pgfault_handler+0x4e>
c01026fd:	68 d7 ba 10 c0       	push   $0xc010bad7
c0102702:	68 eb ba 10 c0       	push   $0xc010baeb
c0102707:	68 c4 00 00 00       	push   $0xc4
c010270c:	68 00 bb 10 c0       	push   $0xc010bb00
c0102711:	e8 70 e6 ff ff       	call   c0100d86 <__panic>
        mm = check_mm_struct;
c0102716:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c010271b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010271e:	eb 47                	jmp    c0102767 <pgfault_handler+0x9f>
    } else {
        if (current == NULL) {
c0102720:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102725:	85 c0                	test   %eax,%eax
c0102727:	75 33                	jne    c010275c <pgfault_handler+0x94>
            print_trapframe(tf);
c0102729:	83 ec 0c             	sub    $0xc,%esp
c010272c:	ff 75 08             	pushl  0x8(%ebp)
c010272f:	e8 86 fc ff ff       	call   c01023ba <print_trapframe>
c0102734:	83 c4 10             	add    $0x10,%esp
            print_pgfault(tf);
c0102737:	83 ec 0c             	sub    $0xc,%esp
c010273a:	ff 75 08             	pushl  0x8(%ebp)
c010273d:	e8 11 ff ff ff       	call   c0102653 <print_pgfault>
c0102742:	83 c4 10             	add    $0x10,%esp
            panic("unhandled page fault.\n");
c0102745:	83 ec 04             	sub    $0x4,%esp
c0102748:	68 11 bb 10 c0       	push   $0xc010bb11
c010274d:	68 ca 00 00 00       	push   $0xca
c0102752:	68 00 bb 10 c0       	push   $0xc010bb00
c0102757:	e8 2a e6 ff ff       	call   c0100d86 <__panic>
        }
        mm = current->mm;
c010275c:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102761:	8b 40 18             	mov    0x18(%eax),%eax
c0102764:	89 45 f4             	mov    %eax,-0xc(%ebp)
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102767:	0f 20 d0             	mov    %cr2,%eax
c010276a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c010276d:	8b 55 f0             	mov    -0x10(%ebp),%edx
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c0102770:	8b 45 08             	mov    0x8(%ebp),%eax
c0102773:	8b 40 34             	mov    0x34(%eax),%eax
c0102776:	83 ec 04             	sub    $0x4,%esp
c0102779:	52                   	push   %edx
c010277a:	50                   	push   %eax
c010277b:	ff 75 f4             	pushl  -0xc(%ebp)
c010277e:	e8 08 5f 00 00       	call   c010868b <do_pgfault>
c0102783:	83 c4 10             	add    $0x10,%esp
}
c0102786:	c9                   	leave  
c0102787:	c3                   	ret    

c0102788 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102788:	55                   	push   %ebp
c0102789:	89 e5                	mov    %esp,%ebp
c010278b:	83 ec 18             	sub    $0x18,%esp
    char c;

    int ret = 0;
c010278e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c0102795:	8b 45 08             	mov    0x8(%ebp),%eax
c0102798:	8b 40 30             	mov    0x30(%eax),%eax
c010279b:	3d 80 00 00 00       	cmp    $0x80,%eax
c01027a0:	0f 84 d8 00 00 00    	je     c010287e <trap_dispatch+0xf6>
c01027a6:	3d 80 00 00 00       	cmp    $0x80,%eax
c01027ab:	0f 87 7f 01 00 00    	ja     c0102930 <trap_dispatch+0x1a8>
c01027b1:	83 f8 2f             	cmp    $0x2f,%eax
c01027b4:	77 1e                	ja     c01027d4 <trap_dispatch+0x4c>
c01027b6:	83 f8 0e             	cmp    $0xe,%eax
c01027b9:	0f 82 71 01 00 00    	jb     c0102930 <trap_dispatch+0x1a8>
c01027bf:	83 e8 0e             	sub    $0xe,%eax
c01027c2:	83 f8 21             	cmp    $0x21,%eax
c01027c5:	0f 87 65 01 00 00    	ja     c0102930 <trap_dispatch+0x1a8>
c01027cb:	8b 04 85 14 bc 10 c0 	mov    -0x3fef43ec(,%eax,4),%eax
c01027d2:	ff e0                	jmp    *%eax
c01027d4:	83 e8 78             	sub    $0x78,%eax
c01027d7:	83 f8 01             	cmp    $0x1,%eax
c01027da:	0f 87 50 01 00 00    	ja     c0102930 <trap_dispatch+0x1a8>
c01027e0:	e9 34 01 00 00       	jmp    c0102919 <trap_dispatch+0x191>
        case T_PGFLT:  //page fault
            if ((ret = pgfault_handler(tf)) != 0) {
c01027e5:	83 ec 0c             	sub    $0xc,%esp
c01027e8:	ff 75 08             	pushl  0x8(%ebp)
c01027eb:	e8 d8 fe ff ff       	call   c01026c8 <pgfault_handler>
c01027f0:	83 c4 10             	add    $0x10,%esp
c01027f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01027f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01027fa:	0f 84 7e 01 00 00    	je     c010297e <trap_dispatch+0x1f6>
                print_trapframe(tf);
c0102800:	83 ec 0c             	sub    $0xc,%esp
c0102803:	ff 75 08             	pushl  0x8(%ebp)
c0102806:	e8 af fb ff ff       	call   c01023ba <print_trapframe>
c010280b:	83 c4 10             	add    $0x10,%esp
                if (current == NULL) {
c010280e:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102813:	85 c0                	test   %eax,%eax
c0102815:	75 17                	jne    c010282e <trap_dispatch+0xa6>
                    panic("handle pgfault failed. ret=%d\n", ret);
c0102817:	ff 75 f4             	pushl  -0xc(%ebp)
c010281a:	68 28 bb 10 c0       	push   $0xc010bb28
c010281f:	68 df 00 00 00       	push   $0xdf
c0102824:	68 00 bb 10 c0       	push   $0xc010bb00
c0102829:	e8 58 e5 ff ff       	call   c0100d86 <__panic>
                } else {
                    if (trap_in_kernel(tf)) {
c010282e:	83 ec 0c             	sub    $0xc,%esp
c0102831:	ff 75 08             	pushl  0x8(%ebp)
c0102834:	e8 6b fb ff ff       	call   c01023a4 <trap_in_kernel>
c0102839:	83 c4 10             	add    $0x10,%esp
c010283c:	85 c0                	test   %eax,%eax
c010283e:	74 17                	je     c0102857 <trap_dispatch+0xcf>
                        panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c0102840:	ff 75 f4             	pushl  -0xc(%ebp)
c0102843:	68 48 bb 10 c0       	push   $0xc010bb48
c0102848:	68 e2 00 00 00       	push   $0xe2
c010284d:	68 00 bb 10 c0       	push   $0xc010bb00
c0102852:	e8 2f e5 ff ff       	call   c0100d86 <__panic>
                    }
                    cprintf("killed by kernel.\n");
c0102857:	83 ec 0c             	sub    $0xc,%esp
c010285a:	68 76 bb 10 c0       	push   $0xc010bb76
c010285f:	e8 e4 da ff ff       	call   c0100348 <cprintf>
c0102864:	83 c4 10             	add    $0x10,%esp
                    panic("handle user mode pgfault failed. ret=%d\n", ret);
c0102867:	ff 75 f4             	pushl  -0xc(%ebp)
c010286a:	68 8c bb 10 c0       	push   $0xc010bb8c
c010286f:	68 e5 00 00 00       	push   $0xe5
c0102874:	68 00 bb 10 c0       	push   $0xc010bb00
c0102879:	e8 08 e5 ff ff       	call   c0100d86 <__panic>
                    do_exit(-E_KILLED);
                }
            }
            break;
        case T_SYSCALL:
            syscall();
c010287e:	e8 73 7f 00 00       	call   c010a7f6 <syscall>
            break;
c0102883:	e9 fa 00 00 00       	jmp    c0102982 <trap_dispatch+0x1fa>
         */
            /* LAB5 YOUR CODE */
            /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
            ticks++;
c0102888:	a1 24 34 1a c0       	mov    0xc01a3424,%eax
c010288d:	83 c0 01             	add    $0x1,%eax
c0102890:	a3 24 34 1a c0       	mov    %eax,0xc01a3424
            if (ticks % TICK_NUM == 0) {
c0102895:	8b 0d 24 34 1a c0    	mov    0xc01a3424,%ecx
c010289b:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01028a0:	89 c8                	mov    %ecx,%eax
c01028a2:	f7 e2                	mul    %edx
c01028a4:	89 d0                	mov    %edx,%eax
c01028a6:	c1 e8 05             	shr    $0x5,%eax
c01028a9:	6b d0 64             	imul   $0x64,%eax,%edx
c01028ac:	89 c8                	mov    %ecx,%eax
c01028ae:	29 d0                	sub    %edx,%eax
c01028b0:	85 c0                	test   %eax,%eax
c01028b2:	0f 85 c9 00 00 00    	jne    c0102981 <trap_dispatch+0x1f9>
                print_ticks();
c01028b8:	e8 a9 f8 ff ff       	call   c0102166 <print_ticks>
                current->need_resched = 1;
c01028bd:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01028c2:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
            }
            break;
c01028c9:	e9 b3 00 00 00       	jmp    c0102981 <trap_dispatch+0x1f9>
        case IRQ_OFFSET + IRQ_COM1:
            c = cons_getc();
c01028ce:	e8 7e ee ff ff       	call   c0101751 <cons_getc>
c01028d3:	88 45 f3             	mov    %al,-0xd(%ebp)
            cprintf("serial [%03d] %c\n", c, c);
c01028d6:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01028da:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01028de:	83 ec 04             	sub    $0x4,%esp
c01028e1:	52                   	push   %edx
c01028e2:	50                   	push   %eax
c01028e3:	68 b5 bb 10 c0       	push   $0xc010bbb5
c01028e8:	e8 5b da ff ff       	call   c0100348 <cprintf>
c01028ed:	83 c4 10             	add    $0x10,%esp
            break;
c01028f0:	e9 8d 00 00 00       	jmp    c0102982 <trap_dispatch+0x1fa>
        case IRQ_OFFSET + IRQ_KBD:
            c = cons_getc();
c01028f5:	e8 57 ee ff ff       	call   c0101751 <cons_getc>
c01028fa:	88 45 f3             	mov    %al,-0xd(%ebp)
            cprintf("kbd [%03d] %c\n", c, c);
c01028fd:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102901:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102905:	83 ec 04             	sub    $0x4,%esp
c0102908:	52                   	push   %edx
c0102909:	50                   	push   %eax
c010290a:	68 c7 bb 10 c0       	push   $0xc010bbc7
c010290f:	e8 34 da ff ff       	call   c0100348 <cprintf>
c0102914:	83 c4 10             	add    $0x10,%esp
            break;
c0102917:	eb 69                	jmp    c0102982 <trap_dispatch+0x1fa>
        //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
        case T_SWITCH_TOU:
        case T_SWITCH_TOK:
            panic("T_SWITCH_** ??\n");
c0102919:	83 ec 04             	sub    $0x4,%esp
c010291c:	68 d6 bb 10 c0       	push   $0xc010bbd6
c0102921:	68 0d 01 00 00       	push   $0x10d
c0102926:	68 00 bb 10 c0       	push   $0xc010bb00
c010292b:	e8 56 e4 ff ff       	call   c0100d86 <__panic>
        case IRQ_OFFSET + IRQ_IDE1:
        case IRQ_OFFSET + IRQ_IDE2:
            /* do nothing */
            break;
        default:
            print_trapframe(tf);
c0102930:	83 ec 0c             	sub    $0xc,%esp
c0102933:	ff 75 08             	pushl  0x8(%ebp)
c0102936:	e8 7f fa ff ff       	call   c01023ba <print_trapframe>
c010293b:	83 c4 10             	add    $0x10,%esp
            if (current != NULL) {
c010293e:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102943:	85 c0                	test   %eax,%eax
c0102945:	74 1d                	je     c0102964 <trap_dispatch+0x1dc>
                cprintf("unhandled trap.\n");
c0102947:	83 ec 0c             	sub    $0xc,%esp
c010294a:	68 e6 bb 10 c0       	push   $0xc010bbe6
c010294f:	e8 f4 d9 ff ff       	call   c0100348 <cprintf>
c0102954:	83 c4 10             	add    $0x10,%esp
                do_exit(-E_KILLED);
c0102957:	83 ec 0c             	sub    $0xc,%esp
c010295a:	6a f7                	push   $0xfffffff7
c010295c:	e8 31 6d 00 00       	call   c0109692 <do_exit>
c0102961:	83 c4 10             	add    $0x10,%esp
            }
            // in kernel, it must be a mistake
            panic("unexpected trap in kernel.\n");
c0102964:	83 ec 04             	sub    $0x4,%esp
c0102967:	68 f7 bb 10 c0       	push   $0xc010bbf7
c010296c:	68 1a 01 00 00       	push   $0x11a
c0102971:	68 00 bb 10 c0       	push   $0xc010bb00
c0102976:	e8 0b e4 ff ff       	call   c0100d86 <__panic>
            break;
c010297b:	90                   	nop
c010297c:	eb 04                	jmp    c0102982 <trap_dispatch+0x1fa>
            break;
c010297e:	90                   	nop
c010297f:	eb 01                	jmp    c0102982 <trap_dispatch+0x1fa>
            break;
c0102981:	90                   	nop
    }
}
c0102982:	90                   	nop
c0102983:	c9                   	leave  
c0102984:	c3                   	ret    

c0102985 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102985:	55                   	push   %ebp
c0102986:	89 e5                	mov    %esp,%ebp
c0102988:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c010298b:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102990:	85 c0                	test   %eax,%eax
c0102992:	75 10                	jne    c01029a4 <trap+0x1f>
        trap_dispatch(tf);
c0102994:	83 ec 0c             	sub    $0xc,%esp
c0102997:	ff 75 08             	pushl  0x8(%ebp)
c010299a:	e8 e9 fd ff ff       	call   c0102788 <trap_dispatch>
c010299f:	83 c4 10             	add    $0x10,%esp
            if (current->need_resched) {
                schedule();
            }
        }
    }
}
c01029a2:	eb 73                	jmp    c0102a17 <trap+0x92>
        struct trapframe *otf = current->tf;
c01029a4:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01029a9:	8b 40 3c             	mov    0x3c(%eax),%eax
c01029ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c01029af:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01029b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01029b7:	89 50 3c             	mov    %edx,0x3c(%eax)
        bool in_kernel = trap_in_kernel(tf);
c01029ba:	83 ec 0c             	sub    $0xc,%esp
c01029bd:	ff 75 08             	pushl  0x8(%ebp)
c01029c0:	e8 df f9 ff ff       	call   c01023a4 <trap_in_kernel>
c01029c5:	83 c4 10             	add    $0x10,%esp
c01029c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        trap_dispatch(tf);
c01029cb:	83 ec 0c             	sub    $0xc,%esp
c01029ce:	ff 75 08             	pushl  0x8(%ebp)
c01029d1:	e8 b2 fd ff ff       	call   c0102788 <trap_dispatch>
c01029d6:	83 c4 10             	add    $0x10,%esp
        current->tf = otf;
c01029d9:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01029de:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01029e1:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c01029e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01029e8:	75 2d                	jne    c0102a17 <trap+0x92>
            if (current->flags & PF_EXITING) {
c01029ea:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01029ef:	8b 40 44             	mov    0x44(%eax),%eax
c01029f2:	83 e0 01             	and    $0x1,%eax
c01029f5:	85 c0                	test   %eax,%eax
c01029f7:	74 0d                	je     c0102a06 <trap+0x81>
                do_exit(-E_KILLED);
c01029f9:	83 ec 0c             	sub    $0xc,%esp
c01029fc:	6a f7                	push   $0xfffffff7
c01029fe:	e8 8f 6c 00 00       	call   c0109692 <do_exit>
c0102a03:	83 c4 10             	add    $0x10,%esp
            if (current->need_resched) {
c0102a06:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102a0b:	8b 40 10             	mov    0x10(%eax),%eax
c0102a0e:	85 c0                	test   %eax,%eax
c0102a10:	74 05                	je     c0102a17 <trap+0x92>
                schedule();
c0102a12:	e8 e6 7b 00 00       	call   c010a5fd <schedule>
}
c0102a17:	90                   	nop
c0102a18:	c9                   	leave  
c0102a19:	c3                   	ret    

c0102a1a <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102a1a:	1e                   	push   %ds
    pushl %es
c0102a1b:	06                   	push   %es
    pushl %fs
c0102a1c:	0f a0                	push   %fs
    pushl %gs
c0102a1e:	0f a8                	push   %gs
    pushal
c0102a20:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102a21:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102a26:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102a28:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102a2a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102a2b:	e8 55 ff ff ff       	call   c0102985 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102a30:	5c                   	pop    %esp

c0102a31 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102a31:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102a32:	0f a9                	pop    %gs
    popl %fs
c0102a34:	0f a1                	pop    %fs
    popl %es
c0102a36:	07                   	pop    %es
    popl %ds
c0102a37:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a38:	83 c4 08             	add    $0x8,%esp
    iret
c0102a3b:	cf                   	iret   

c0102a3c <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102a3c:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102a40:	eb ef                	jmp    c0102a31 <__trapret>

c0102a42 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $0
c0102a44:	6a 00                	push   $0x0
  jmp __alltraps
c0102a46:	e9 cf ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a4b <vector1>:
.globl vector1
vector1:
  pushl $0
c0102a4b:	6a 00                	push   $0x0
  pushl $1
c0102a4d:	6a 01                	push   $0x1
  jmp __alltraps
c0102a4f:	e9 c6 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a54 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102a54:	6a 00                	push   $0x0
  pushl $2
c0102a56:	6a 02                	push   $0x2
  jmp __alltraps
c0102a58:	e9 bd ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a5d <vector3>:
.globl vector3
vector3:
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  pushl $3
c0102a5f:	6a 03                	push   $0x3
  jmp __alltraps
c0102a61:	e9 b4 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a66 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102a66:	6a 00                	push   $0x0
  pushl $4
c0102a68:	6a 04                	push   $0x4
  jmp __alltraps
c0102a6a:	e9 ab ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a6f <vector5>:
.globl vector5
vector5:
  pushl $0
c0102a6f:	6a 00                	push   $0x0
  pushl $5
c0102a71:	6a 05                	push   $0x5
  jmp __alltraps
c0102a73:	e9 a2 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a78 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $6
c0102a7a:	6a 06                	push   $0x6
  jmp __alltraps
c0102a7c:	e9 99 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a81 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102a81:	6a 00                	push   $0x0
  pushl $7
c0102a83:	6a 07                	push   $0x7
  jmp __alltraps
c0102a85:	e9 90 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a8a <vector8>:
.globl vector8
vector8:
  pushl $8
c0102a8a:	6a 08                	push   $0x8
  jmp __alltraps
c0102a8c:	e9 89 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a91 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102a91:	6a 00                	push   $0x0
  pushl $9
c0102a93:	6a 09                	push   $0x9
  jmp __alltraps
c0102a95:	e9 80 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102a9a <vector10>:
.globl vector10
vector10:
  pushl $10
c0102a9a:	6a 0a                	push   $0xa
  jmp __alltraps
c0102a9c:	e9 79 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102aa1 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102aa1:	6a 0b                	push   $0xb
  jmp __alltraps
c0102aa3:	e9 72 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102aa8 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102aa8:	6a 0c                	push   $0xc
  jmp __alltraps
c0102aaa:	e9 6b ff ff ff       	jmp    c0102a1a <__alltraps>

c0102aaf <vector13>:
.globl vector13
vector13:
  pushl $13
c0102aaf:	6a 0d                	push   $0xd
  jmp __alltraps
c0102ab1:	e9 64 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102ab6 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102ab6:	6a 0e                	push   $0xe
  jmp __alltraps
c0102ab8:	e9 5d ff ff ff       	jmp    c0102a1a <__alltraps>

c0102abd <vector15>:
.globl vector15
vector15:
  pushl $0
c0102abd:	6a 00                	push   $0x0
  pushl $15
c0102abf:	6a 0f                	push   $0xf
  jmp __alltraps
c0102ac1:	e9 54 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102ac6 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102ac6:	6a 00                	push   $0x0
  pushl $16
c0102ac8:	6a 10                	push   $0x10
  jmp __alltraps
c0102aca:	e9 4b ff ff ff       	jmp    c0102a1a <__alltraps>

c0102acf <vector17>:
.globl vector17
vector17:
  pushl $17
c0102acf:	6a 11                	push   $0x11
  jmp __alltraps
c0102ad1:	e9 44 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102ad6 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102ad6:	6a 00                	push   $0x0
  pushl $18
c0102ad8:	6a 12                	push   $0x12
  jmp __alltraps
c0102ada:	e9 3b ff ff ff       	jmp    c0102a1a <__alltraps>

c0102adf <vector19>:
.globl vector19
vector19:
  pushl $0
c0102adf:	6a 00                	push   $0x0
  pushl $19
c0102ae1:	6a 13                	push   $0x13
  jmp __alltraps
c0102ae3:	e9 32 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102ae8 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $20
c0102aea:	6a 14                	push   $0x14
  jmp __alltraps
c0102aec:	e9 29 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102af1 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102af1:	6a 00                	push   $0x0
  pushl $21
c0102af3:	6a 15                	push   $0x15
  jmp __alltraps
c0102af5:	e9 20 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102afa <vector22>:
.globl vector22
vector22:
  pushl $0
c0102afa:	6a 00                	push   $0x0
  pushl $22
c0102afc:	6a 16                	push   $0x16
  jmp __alltraps
c0102afe:	e9 17 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102b03 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b03:	6a 00                	push   $0x0
  pushl $23
c0102b05:	6a 17                	push   $0x17
  jmp __alltraps
c0102b07:	e9 0e ff ff ff       	jmp    c0102a1a <__alltraps>

c0102b0c <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b0c:	6a 00                	push   $0x0
  pushl $24
c0102b0e:	6a 18                	push   $0x18
  jmp __alltraps
c0102b10:	e9 05 ff ff ff       	jmp    c0102a1a <__alltraps>

c0102b15 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b15:	6a 00                	push   $0x0
  pushl $25
c0102b17:	6a 19                	push   $0x19
  jmp __alltraps
c0102b19:	e9 fc fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b1e <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b1e:	6a 00                	push   $0x0
  pushl $26
c0102b20:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b22:	e9 f3 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b27 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b27:	6a 00                	push   $0x0
  pushl $27
c0102b29:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102b2b:	e9 ea fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b30 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102b30:	6a 00                	push   $0x0
  pushl $28
c0102b32:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102b34:	e9 e1 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b39 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102b39:	6a 00                	push   $0x0
  pushl $29
c0102b3b:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102b3d:	e9 d8 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b42 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102b42:	6a 00                	push   $0x0
  pushl $30
c0102b44:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102b46:	e9 cf fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b4b <vector31>:
.globl vector31
vector31:
  pushl $0
c0102b4b:	6a 00                	push   $0x0
  pushl $31
c0102b4d:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102b4f:	e9 c6 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b54 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102b54:	6a 00                	push   $0x0
  pushl $32
c0102b56:	6a 20                	push   $0x20
  jmp __alltraps
c0102b58:	e9 bd fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b5d <vector33>:
.globl vector33
vector33:
  pushl $0
c0102b5d:	6a 00                	push   $0x0
  pushl $33
c0102b5f:	6a 21                	push   $0x21
  jmp __alltraps
c0102b61:	e9 b4 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b66 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $34
c0102b68:	6a 22                	push   $0x22
  jmp __alltraps
c0102b6a:	e9 ab fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b6f <vector35>:
.globl vector35
vector35:
  pushl $0
c0102b6f:	6a 00                	push   $0x0
  pushl $35
c0102b71:	6a 23                	push   $0x23
  jmp __alltraps
c0102b73:	e9 a2 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b78 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102b78:	6a 00                	push   $0x0
  pushl $36
c0102b7a:	6a 24                	push   $0x24
  jmp __alltraps
c0102b7c:	e9 99 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b81 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102b81:	6a 00                	push   $0x0
  pushl $37
c0102b83:	6a 25                	push   $0x25
  jmp __alltraps
c0102b85:	e9 90 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b8a <vector38>:
.globl vector38
vector38:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $38
c0102b8c:	6a 26                	push   $0x26
  jmp __alltraps
c0102b8e:	e9 87 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b93 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102b93:	6a 00                	push   $0x0
  pushl $39
c0102b95:	6a 27                	push   $0x27
  jmp __alltraps
c0102b97:	e9 7e fe ff ff       	jmp    c0102a1a <__alltraps>

c0102b9c <vector40>:
.globl vector40
vector40:
  pushl $0
c0102b9c:	6a 00                	push   $0x0
  pushl $40
c0102b9e:	6a 28                	push   $0x28
  jmp __alltraps
c0102ba0:	e9 75 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102ba5 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102ba5:	6a 00                	push   $0x0
  pushl $41
c0102ba7:	6a 29                	push   $0x29
  jmp __alltraps
c0102ba9:	e9 6c fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bae <vector42>:
.globl vector42
vector42:
  pushl $0
c0102bae:	6a 00                	push   $0x0
  pushl $42
c0102bb0:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102bb2:	e9 63 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bb7 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102bb7:	6a 00                	push   $0x0
  pushl $43
c0102bb9:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102bbb:	e9 5a fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bc0 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102bc0:	6a 00                	push   $0x0
  pushl $44
c0102bc2:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102bc4:	e9 51 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bc9 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102bc9:	6a 00                	push   $0x0
  pushl $45
c0102bcb:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102bcd:	e9 48 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bd2 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102bd2:	6a 00                	push   $0x0
  pushl $46
c0102bd4:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102bd6:	e9 3f fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bdb <vector47>:
.globl vector47
vector47:
  pushl $0
c0102bdb:	6a 00                	push   $0x0
  pushl $47
c0102bdd:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102bdf:	e9 36 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102be4 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102be4:	6a 00                	push   $0x0
  pushl $48
c0102be6:	6a 30                	push   $0x30
  jmp __alltraps
c0102be8:	e9 2d fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bed <vector49>:
.globl vector49
vector49:
  pushl $0
c0102bed:	6a 00                	push   $0x0
  pushl $49
c0102bef:	6a 31                	push   $0x31
  jmp __alltraps
c0102bf1:	e9 24 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bf6 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102bf6:	6a 00                	push   $0x0
  pushl $50
c0102bf8:	6a 32                	push   $0x32
  jmp __alltraps
c0102bfa:	e9 1b fe ff ff       	jmp    c0102a1a <__alltraps>

c0102bff <vector51>:
.globl vector51
vector51:
  pushl $0
c0102bff:	6a 00                	push   $0x0
  pushl $51
c0102c01:	6a 33                	push   $0x33
  jmp __alltraps
c0102c03:	e9 12 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102c08 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c08:	6a 00                	push   $0x0
  pushl $52
c0102c0a:	6a 34                	push   $0x34
  jmp __alltraps
c0102c0c:	e9 09 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102c11 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $53
c0102c13:	6a 35                	push   $0x35
  jmp __alltraps
c0102c15:	e9 00 fe ff ff       	jmp    c0102a1a <__alltraps>

c0102c1a <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $54
c0102c1c:	6a 36                	push   $0x36
  jmp __alltraps
c0102c1e:	e9 f7 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c23 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $55
c0102c25:	6a 37                	push   $0x37
  jmp __alltraps
c0102c27:	e9 ee fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c2c <vector56>:
.globl vector56
vector56:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $56
c0102c2e:	6a 38                	push   $0x38
  jmp __alltraps
c0102c30:	e9 e5 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c35 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $57
c0102c37:	6a 39                	push   $0x39
  jmp __alltraps
c0102c39:	e9 dc fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c3e <vector58>:
.globl vector58
vector58:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $58
c0102c40:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102c42:	e9 d3 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c47 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $59
c0102c49:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102c4b:	e9 ca fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c50 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $60
c0102c52:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102c54:	e9 c1 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c59 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $61
c0102c5b:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102c5d:	e9 b8 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c62 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $62
c0102c64:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102c66:	e9 af fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c6b <vector63>:
.globl vector63
vector63:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $63
c0102c6d:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102c6f:	e9 a6 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c74 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $64
c0102c76:	6a 40                	push   $0x40
  jmp __alltraps
c0102c78:	e9 9d fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c7d <vector65>:
.globl vector65
vector65:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $65
c0102c7f:	6a 41                	push   $0x41
  jmp __alltraps
c0102c81:	e9 94 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c86 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $66
c0102c88:	6a 42                	push   $0x42
  jmp __alltraps
c0102c8a:	e9 8b fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c8f <vector67>:
.globl vector67
vector67:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $67
c0102c91:	6a 43                	push   $0x43
  jmp __alltraps
c0102c93:	e9 82 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102c98 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $68
c0102c9a:	6a 44                	push   $0x44
  jmp __alltraps
c0102c9c:	e9 79 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102ca1 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $69
c0102ca3:	6a 45                	push   $0x45
  jmp __alltraps
c0102ca5:	e9 70 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102caa <vector70>:
.globl vector70
vector70:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $70
c0102cac:	6a 46                	push   $0x46
  jmp __alltraps
c0102cae:	e9 67 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102cb3 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $71
c0102cb5:	6a 47                	push   $0x47
  jmp __alltraps
c0102cb7:	e9 5e fd ff ff       	jmp    c0102a1a <__alltraps>

c0102cbc <vector72>:
.globl vector72
vector72:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $72
c0102cbe:	6a 48                	push   $0x48
  jmp __alltraps
c0102cc0:	e9 55 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102cc5 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $73
c0102cc7:	6a 49                	push   $0x49
  jmp __alltraps
c0102cc9:	e9 4c fd ff ff       	jmp    c0102a1a <__alltraps>

c0102cce <vector74>:
.globl vector74
vector74:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $74
c0102cd0:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102cd2:	e9 43 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102cd7 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102cd7:	6a 00                	push   $0x0
  pushl $75
c0102cd9:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102cdb:	e9 3a fd ff ff       	jmp    c0102a1a <__alltraps>

c0102ce0 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102ce0:	6a 00                	push   $0x0
  pushl $76
c0102ce2:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102ce4:	e9 31 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102ce9 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $77
c0102ceb:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102ced:	e9 28 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102cf2 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $78
c0102cf4:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102cf6:	e9 1f fd ff ff       	jmp    c0102a1a <__alltraps>

c0102cfb <vector79>:
.globl vector79
vector79:
  pushl $0
c0102cfb:	6a 00                	push   $0x0
  pushl $79
c0102cfd:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102cff:	e9 16 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102d04 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d04:	6a 00                	push   $0x0
  pushl $80
c0102d06:	6a 50                	push   $0x50
  jmp __alltraps
c0102d08:	e9 0d fd ff ff       	jmp    c0102a1a <__alltraps>

c0102d0d <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $81
c0102d0f:	6a 51                	push   $0x51
  jmp __alltraps
c0102d11:	e9 04 fd ff ff       	jmp    c0102a1a <__alltraps>

c0102d16 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $82
c0102d18:	6a 52                	push   $0x52
  jmp __alltraps
c0102d1a:	e9 fb fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d1f <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d1f:	6a 00                	push   $0x0
  pushl $83
c0102d21:	6a 53                	push   $0x53
  jmp __alltraps
c0102d23:	e9 f2 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d28 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d28:	6a 00                	push   $0x0
  pushl $84
c0102d2a:	6a 54                	push   $0x54
  jmp __alltraps
c0102d2c:	e9 e9 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d31 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $85
c0102d33:	6a 55                	push   $0x55
  jmp __alltraps
c0102d35:	e9 e0 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d3a <vector86>:
.globl vector86
vector86:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $86
c0102d3c:	6a 56                	push   $0x56
  jmp __alltraps
c0102d3e:	e9 d7 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d43 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102d43:	6a 00                	push   $0x0
  pushl $87
c0102d45:	6a 57                	push   $0x57
  jmp __alltraps
c0102d47:	e9 ce fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d4c <vector88>:
.globl vector88
vector88:
  pushl $0
c0102d4c:	6a 00                	push   $0x0
  pushl $88
c0102d4e:	6a 58                	push   $0x58
  jmp __alltraps
c0102d50:	e9 c5 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d55 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $89
c0102d57:	6a 59                	push   $0x59
  jmp __alltraps
c0102d59:	e9 bc fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d5e <vector90>:
.globl vector90
vector90:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $90
c0102d60:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102d62:	e9 b3 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d67 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102d67:	6a 00                	push   $0x0
  pushl $91
c0102d69:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102d6b:	e9 aa fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d70 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102d70:	6a 00                	push   $0x0
  pushl $92
c0102d72:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102d74:	e9 a1 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d79 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102d79:	6a 00                	push   $0x0
  pushl $93
c0102d7b:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102d7d:	e9 98 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d82 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $94
c0102d84:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102d86:	e9 8f fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d8b <vector95>:
.globl vector95
vector95:
  pushl $0
c0102d8b:	6a 00                	push   $0x0
  pushl $95
c0102d8d:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102d8f:	e9 86 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d94 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102d94:	6a 00                	push   $0x0
  pushl $96
c0102d96:	6a 60                	push   $0x60
  jmp __alltraps
c0102d98:	e9 7d fc ff ff       	jmp    c0102a1a <__alltraps>

c0102d9d <vector97>:
.globl vector97
vector97:
  pushl $0
c0102d9d:	6a 00                	push   $0x0
  pushl $97
c0102d9f:	6a 61                	push   $0x61
  jmp __alltraps
c0102da1:	e9 74 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102da6 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $98
c0102da8:	6a 62                	push   $0x62
  jmp __alltraps
c0102daa:	e9 6b fc ff ff       	jmp    c0102a1a <__alltraps>

c0102daf <vector99>:
.globl vector99
vector99:
  pushl $0
c0102daf:	6a 00                	push   $0x0
  pushl $99
c0102db1:	6a 63                	push   $0x63
  jmp __alltraps
c0102db3:	e9 62 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102db8 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102db8:	6a 00                	push   $0x0
  pushl $100
c0102dba:	6a 64                	push   $0x64
  jmp __alltraps
c0102dbc:	e9 59 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102dc1 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $101
c0102dc3:	6a 65                	push   $0x65
  jmp __alltraps
c0102dc5:	e9 50 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102dca <vector102>:
.globl vector102
vector102:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $102
c0102dcc:	6a 66                	push   $0x66
  jmp __alltraps
c0102dce:	e9 47 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102dd3 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102dd3:	6a 00                	push   $0x0
  pushl $103
c0102dd5:	6a 67                	push   $0x67
  jmp __alltraps
c0102dd7:	e9 3e fc ff ff       	jmp    c0102a1a <__alltraps>

c0102ddc <vector104>:
.globl vector104
vector104:
  pushl $0
c0102ddc:	6a 00                	push   $0x0
  pushl $104
c0102dde:	6a 68                	push   $0x68
  jmp __alltraps
c0102de0:	e9 35 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102de5 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $105
c0102de7:	6a 69                	push   $0x69
  jmp __alltraps
c0102de9:	e9 2c fc ff ff       	jmp    c0102a1a <__alltraps>

c0102dee <vector106>:
.globl vector106
vector106:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $106
c0102df0:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102df2:	e9 23 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102df7 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102df7:	6a 00                	push   $0x0
  pushl $107
c0102df9:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102dfb:	e9 1a fc ff ff       	jmp    c0102a1a <__alltraps>

c0102e00 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102e00:	6a 00                	push   $0x0
  pushl $108
c0102e02:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e04:	e9 11 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102e09 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $109
c0102e0b:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e0d:	e9 08 fc ff ff       	jmp    c0102a1a <__alltraps>

c0102e12 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $110
c0102e14:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e16:	e9 ff fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e1b <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e1b:	6a 00                	push   $0x0
  pushl $111
c0102e1d:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e1f:	e9 f6 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e24 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e24:	6a 00                	push   $0x0
  pushl $112
c0102e26:	6a 70                	push   $0x70
  jmp __alltraps
c0102e28:	e9 ed fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e2d <vector113>:
.globl vector113
vector113:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $113
c0102e2f:	6a 71                	push   $0x71
  jmp __alltraps
c0102e31:	e9 e4 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e36 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $114
c0102e38:	6a 72                	push   $0x72
  jmp __alltraps
c0102e3a:	e9 db fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e3f <vector115>:
.globl vector115
vector115:
  pushl $0
c0102e3f:	6a 00                	push   $0x0
  pushl $115
c0102e41:	6a 73                	push   $0x73
  jmp __alltraps
c0102e43:	e9 d2 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e48 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102e48:	6a 00                	push   $0x0
  pushl $116
c0102e4a:	6a 74                	push   $0x74
  jmp __alltraps
c0102e4c:	e9 c9 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e51 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $117
c0102e53:	6a 75                	push   $0x75
  jmp __alltraps
c0102e55:	e9 c0 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e5a <vector118>:
.globl vector118
vector118:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $118
c0102e5c:	6a 76                	push   $0x76
  jmp __alltraps
c0102e5e:	e9 b7 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e63 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102e63:	6a 00                	push   $0x0
  pushl $119
c0102e65:	6a 77                	push   $0x77
  jmp __alltraps
c0102e67:	e9 ae fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e6c <vector120>:
.globl vector120
vector120:
  pushl $0
c0102e6c:	6a 00                	push   $0x0
  pushl $120
c0102e6e:	6a 78                	push   $0x78
  jmp __alltraps
c0102e70:	e9 a5 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e75 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $121
c0102e77:	6a 79                	push   $0x79
  jmp __alltraps
c0102e79:	e9 9c fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e7e <vector122>:
.globl vector122
vector122:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $122
c0102e80:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102e82:	e9 93 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e87 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102e87:	6a 00                	push   $0x0
  pushl $123
c0102e89:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102e8b:	e9 8a fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e90 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102e90:	6a 00                	push   $0x0
  pushl $124
c0102e92:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102e94:	e9 81 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102e99 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $125
c0102e9b:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102e9d:	e9 78 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102ea2 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $126
c0102ea4:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ea6:	e9 6f fb ff ff       	jmp    c0102a1a <__alltraps>

c0102eab <vector127>:
.globl vector127
vector127:
  pushl $0
c0102eab:	6a 00                	push   $0x0
  pushl $127
c0102ead:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102eaf:	e9 66 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102eb4 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102eb4:	6a 00                	push   $0x0
  pushl $128
c0102eb6:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102ebb:	e9 5a fb ff ff       	jmp    c0102a1a <__alltraps>

c0102ec0 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102ec0:	6a 00                	push   $0x0
  pushl $129
c0102ec2:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ec7:	e9 4e fb ff ff       	jmp    c0102a1a <__alltraps>

c0102ecc <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ecc:	6a 00                	push   $0x0
  pushl $130
c0102ece:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102ed3:	e9 42 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102ed8 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102ed8:	6a 00                	push   $0x0
  pushl $131
c0102eda:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102edf:	e9 36 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102ee4 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102ee4:	6a 00                	push   $0x0
  pushl $132
c0102ee6:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102eeb:	e9 2a fb ff ff       	jmp    c0102a1a <__alltraps>

c0102ef0 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102ef0:	6a 00                	push   $0x0
  pushl $133
c0102ef2:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102ef7:	e9 1e fb ff ff       	jmp    c0102a1a <__alltraps>

c0102efc <vector134>:
.globl vector134
vector134:
  pushl $0
c0102efc:	6a 00                	push   $0x0
  pushl $134
c0102efe:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f03:	e9 12 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102f08 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f08:	6a 00                	push   $0x0
  pushl $135
c0102f0a:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f0f:	e9 06 fb ff ff       	jmp    c0102a1a <__alltraps>

c0102f14 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f14:	6a 00                	push   $0x0
  pushl $136
c0102f16:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f1b:	e9 fa fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f20 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f20:	6a 00                	push   $0x0
  pushl $137
c0102f22:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f27:	e9 ee fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f2c <vector138>:
.globl vector138
vector138:
  pushl $0
c0102f2c:	6a 00                	push   $0x0
  pushl $138
c0102f2e:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102f33:	e9 e2 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f38 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102f38:	6a 00                	push   $0x0
  pushl $139
c0102f3a:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102f3f:	e9 d6 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f44 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102f44:	6a 00                	push   $0x0
  pushl $140
c0102f46:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102f4b:	e9 ca fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f50 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102f50:	6a 00                	push   $0x0
  pushl $141
c0102f52:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102f57:	e9 be fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f5c <vector142>:
.globl vector142
vector142:
  pushl $0
c0102f5c:	6a 00                	push   $0x0
  pushl $142
c0102f5e:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102f63:	e9 b2 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f68 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102f68:	6a 00                	push   $0x0
  pushl $143
c0102f6a:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102f6f:	e9 a6 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f74 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102f74:	6a 00                	push   $0x0
  pushl $144
c0102f76:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102f7b:	e9 9a fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f80 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102f80:	6a 00                	push   $0x0
  pushl $145
c0102f82:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102f87:	e9 8e fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f8c <vector146>:
.globl vector146
vector146:
  pushl $0
c0102f8c:	6a 00                	push   $0x0
  pushl $146
c0102f8e:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102f93:	e9 82 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102f98 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102f98:	6a 00                	push   $0x0
  pushl $147
c0102f9a:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102f9f:	e9 76 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102fa4 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102fa4:	6a 00                	push   $0x0
  pushl $148
c0102fa6:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102fab:	e9 6a fa ff ff       	jmp    c0102a1a <__alltraps>

c0102fb0 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102fb0:	6a 00                	push   $0x0
  pushl $149
c0102fb2:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102fb7:	e9 5e fa ff ff       	jmp    c0102a1a <__alltraps>

c0102fbc <vector150>:
.globl vector150
vector150:
  pushl $0
c0102fbc:	6a 00                	push   $0x0
  pushl $150
c0102fbe:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102fc3:	e9 52 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102fc8 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102fc8:	6a 00                	push   $0x0
  pushl $151
c0102fca:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102fcf:	e9 46 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102fd4 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102fd4:	6a 00                	push   $0x0
  pushl $152
c0102fd6:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102fdb:	e9 3a fa ff ff       	jmp    c0102a1a <__alltraps>

c0102fe0 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102fe0:	6a 00                	push   $0x0
  pushl $153
c0102fe2:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102fe7:	e9 2e fa ff ff       	jmp    c0102a1a <__alltraps>

c0102fec <vector154>:
.globl vector154
vector154:
  pushl $0
c0102fec:	6a 00                	push   $0x0
  pushl $154
c0102fee:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102ff3:	e9 22 fa ff ff       	jmp    c0102a1a <__alltraps>

c0102ff8 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102ff8:	6a 00                	push   $0x0
  pushl $155
c0102ffa:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102fff:	e9 16 fa ff ff       	jmp    c0102a1a <__alltraps>

c0103004 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103004:	6a 00                	push   $0x0
  pushl $156
c0103006:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010300b:	e9 0a fa ff ff       	jmp    c0102a1a <__alltraps>

c0103010 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103010:	6a 00                	push   $0x0
  pushl $157
c0103012:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103017:	e9 fe f9 ff ff       	jmp    c0102a1a <__alltraps>

c010301c <vector158>:
.globl vector158
vector158:
  pushl $0
c010301c:	6a 00                	push   $0x0
  pushl $158
c010301e:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103023:	e9 f2 f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103028 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103028:	6a 00                	push   $0x0
  pushl $159
c010302a:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010302f:	e9 e6 f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103034 <vector160>:
.globl vector160
vector160:
  pushl $0
c0103034:	6a 00                	push   $0x0
  pushl $160
c0103036:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010303b:	e9 da f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103040 <vector161>:
.globl vector161
vector161:
  pushl $0
c0103040:	6a 00                	push   $0x0
  pushl $161
c0103042:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0103047:	e9 ce f9 ff ff       	jmp    c0102a1a <__alltraps>

c010304c <vector162>:
.globl vector162
vector162:
  pushl $0
c010304c:	6a 00                	push   $0x0
  pushl $162
c010304e:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0103053:	e9 c2 f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103058 <vector163>:
.globl vector163
vector163:
  pushl $0
c0103058:	6a 00                	push   $0x0
  pushl $163
c010305a:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010305f:	e9 b6 f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103064 <vector164>:
.globl vector164
vector164:
  pushl $0
c0103064:	6a 00                	push   $0x0
  pushl $164
c0103066:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010306b:	e9 aa f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103070 <vector165>:
.globl vector165
vector165:
  pushl $0
c0103070:	6a 00                	push   $0x0
  pushl $165
c0103072:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0103077:	e9 9e f9 ff ff       	jmp    c0102a1a <__alltraps>

c010307c <vector166>:
.globl vector166
vector166:
  pushl $0
c010307c:	6a 00                	push   $0x0
  pushl $166
c010307e:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0103083:	e9 92 f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103088 <vector167>:
.globl vector167
vector167:
  pushl $0
c0103088:	6a 00                	push   $0x0
  pushl $167
c010308a:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010308f:	e9 86 f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103094 <vector168>:
.globl vector168
vector168:
  pushl $0
c0103094:	6a 00                	push   $0x0
  pushl $168
c0103096:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010309b:	e9 7a f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030a0 <vector169>:
.globl vector169
vector169:
  pushl $0
c01030a0:	6a 00                	push   $0x0
  pushl $169
c01030a2:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01030a7:	e9 6e f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030ac <vector170>:
.globl vector170
vector170:
  pushl $0
c01030ac:	6a 00                	push   $0x0
  pushl $170
c01030ae:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01030b3:	e9 62 f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030b8 <vector171>:
.globl vector171
vector171:
  pushl $0
c01030b8:	6a 00                	push   $0x0
  pushl $171
c01030ba:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01030bf:	e9 56 f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030c4 <vector172>:
.globl vector172
vector172:
  pushl $0
c01030c4:	6a 00                	push   $0x0
  pushl $172
c01030c6:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01030cb:	e9 4a f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030d0 <vector173>:
.globl vector173
vector173:
  pushl $0
c01030d0:	6a 00                	push   $0x0
  pushl $173
c01030d2:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01030d7:	e9 3e f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030dc <vector174>:
.globl vector174
vector174:
  pushl $0
c01030dc:	6a 00                	push   $0x0
  pushl $174
c01030de:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01030e3:	e9 32 f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030e8 <vector175>:
.globl vector175
vector175:
  pushl $0
c01030e8:	6a 00                	push   $0x0
  pushl $175
c01030ea:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01030ef:	e9 26 f9 ff ff       	jmp    c0102a1a <__alltraps>

c01030f4 <vector176>:
.globl vector176
vector176:
  pushl $0
c01030f4:	6a 00                	push   $0x0
  pushl $176
c01030f6:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01030fb:	e9 1a f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103100 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103100:	6a 00                	push   $0x0
  pushl $177
c0103102:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103107:	e9 0e f9 ff ff       	jmp    c0102a1a <__alltraps>

c010310c <vector178>:
.globl vector178
vector178:
  pushl $0
c010310c:	6a 00                	push   $0x0
  pushl $178
c010310e:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103113:	e9 02 f9 ff ff       	jmp    c0102a1a <__alltraps>

c0103118 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103118:	6a 00                	push   $0x0
  pushl $179
c010311a:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010311f:	e9 f6 f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103124 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103124:	6a 00                	push   $0x0
  pushl $180
c0103126:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010312b:	e9 ea f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103130 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103130:	6a 00                	push   $0x0
  pushl $181
c0103132:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103137:	e9 de f8 ff ff       	jmp    c0102a1a <__alltraps>

c010313c <vector182>:
.globl vector182
vector182:
  pushl $0
c010313c:	6a 00                	push   $0x0
  pushl $182
c010313e:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0103143:	e9 d2 f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103148 <vector183>:
.globl vector183
vector183:
  pushl $0
c0103148:	6a 00                	push   $0x0
  pushl $183
c010314a:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010314f:	e9 c6 f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103154 <vector184>:
.globl vector184
vector184:
  pushl $0
c0103154:	6a 00                	push   $0x0
  pushl $184
c0103156:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010315b:	e9 ba f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103160 <vector185>:
.globl vector185
vector185:
  pushl $0
c0103160:	6a 00                	push   $0x0
  pushl $185
c0103162:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103167:	e9 ae f8 ff ff       	jmp    c0102a1a <__alltraps>

c010316c <vector186>:
.globl vector186
vector186:
  pushl $0
c010316c:	6a 00                	push   $0x0
  pushl $186
c010316e:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0103173:	e9 a2 f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103178 <vector187>:
.globl vector187
vector187:
  pushl $0
c0103178:	6a 00                	push   $0x0
  pushl $187
c010317a:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010317f:	e9 96 f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103184 <vector188>:
.globl vector188
vector188:
  pushl $0
c0103184:	6a 00                	push   $0x0
  pushl $188
c0103186:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010318b:	e9 8a f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103190 <vector189>:
.globl vector189
vector189:
  pushl $0
c0103190:	6a 00                	push   $0x0
  pushl $189
c0103192:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0103197:	e9 7e f8 ff ff       	jmp    c0102a1a <__alltraps>

c010319c <vector190>:
.globl vector190
vector190:
  pushl $0
c010319c:	6a 00                	push   $0x0
  pushl $190
c010319e:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01031a3:	e9 72 f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031a8 <vector191>:
.globl vector191
vector191:
  pushl $0
c01031a8:	6a 00                	push   $0x0
  pushl $191
c01031aa:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01031af:	e9 66 f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031b4 <vector192>:
.globl vector192
vector192:
  pushl $0
c01031b4:	6a 00                	push   $0x0
  pushl $192
c01031b6:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01031bb:	e9 5a f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031c0 <vector193>:
.globl vector193
vector193:
  pushl $0
c01031c0:	6a 00                	push   $0x0
  pushl $193
c01031c2:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01031c7:	e9 4e f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031cc <vector194>:
.globl vector194
vector194:
  pushl $0
c01031cc:	6a 00                	push   $0x0
  pushl $194
c01031ce:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01031d3:	e9 42 f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031d8 <vector195>:
.globl vector195
vector195:
  pushl $0
c01031d8:	6a 00                	push   $0x0
  pushl $195
c01031da:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01031df:	e9 36 f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031e4 <vector196>:
.globl vector196
vector196:
  pushl $0
c01031e4:	6a 00                	push   $0x0
  pushl $196
c01031e6:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01031eb:	e9 2a f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031f0 <vector197>:
.globl vector197
vector197:
  pushl $0
c01031f0:	6a 00                	push   $0x0
  pushl $197
c01031f2:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01031f7:	e9 1e f8 ff ff       	jmp    c0102a1a <__alltraps>

c01031fc <vector198>:
.globl vector198
vector198:
  pushl $0
c01031fc:	6a 00                	push   $0x0
  pushl $198
c01031fe:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103203:	e9 12 f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103208 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103208:	6a 00                	push   $0x0
  pushl $199
c010320a:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010320f:	e9 06 f8 ff ff       	jmp    c0102a1a <__alltraps>

c0103214 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103214:	6a 00                	push   $0x0
  pushl $200
c0103216:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010321b:	e9 fa f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103220 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103220:	6a 00                	push   $0x0
  pushl $201
c0103222:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103227:	e9 ee f7 ff ff       	jmp    c0102a1a <__alltraps>

c010322c <vector202>:
.globl vector202
vector202:
  pushl $0
c010322c:	6a 00                	push   $0x0
  pushl $202
c010322e:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103233:	e9 e2 f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103238 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103238:	6a 00                	push   $0x0
  pushl $203
c010323a:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010323f:	e9 d6 f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103244 <vector204>:
.globl vector204
vector204:
  pushl $0
c0103244:	6a 00                	push   $0x0
  pushl $204
c0103246:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010324b:	e9 ca f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103250 <vector205>:
.globl vector205
vector205:
  pushl $0
c0103250:	6a 00                	push   $0x0
  pushl $205
c0103252:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103257:	e9 be f7 ff ff       	jmp    c0102a1a <__alltraps>

c010325c <vector206>:
.globl vector206
vector206:
  pushl $0
c010325c:	6a 00                	push   $0x0
  pushl $206
c010325e:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0103263:	e9 b2 f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103268 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103268:	6a 00                	push   $0x0
  pushl $207
c010326a:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010326f:	e9 a6 f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103274 <vector208>:
.globl vector208
vector208:
  pushl $0
c0103274:	6a 00                	push   $0x0
  pushl $208
c0103276:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010327b:	e9 9a f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103280 <vector209>:
.globl vector209
vector209:
  pushl $0
c0103280:	6a 00                	push   $0x0
  pushl $209
c0103282:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0103287:	e9 8e f7 ff ff       	jmp    c0102a1a <__alltraps>

c010328c <vector210>:
.globl vector210
vector210:
  pushl $0
c010328c:	6a 00                	push   $0x0
  pushl $210
c010328e:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0103293:	e9 82 f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103298 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103298:	6a 00                	push   $0x0
  pushl $211
c010329a:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010329f:	e9 76 f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032a4 <vector212>:
.globl vector212
vector212:
  pushl $0
c01032a4:	6a 00                	push   $0x0
  pushl $212
c01032a6:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01032ab:	e9 6a f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032b0 <vector213>:
.globl vector213
vector213:
  pushl $0
c01032b0:	6a 00                	push   $0x0
  pushl $213
c01032b2:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01032b7:	e9 5e f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032bc <vector214>:
.globl vector214
vector214:
  pushl $0
c01032bc:	6a 00                	push   $0x0
  pushl $214
c01032be:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01032c3:	e9 52 f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032c8 <vector215>:
.globl vector215
vector215:
  pushl $0
c01032c8:	6a 00                	push   $0x0
  pushl $215
c01032ca:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01032cf:	e9 46 f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032d4 <vector216>:
.globl vector216
vector216:
  pushl $0
c01032d4:	6a 00                	push   $0x0
  pushl $216
c01032d6:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01032db:	e9 3a f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032e0 <vector217>:
.globl vector217
vector217:
  pushl $0
c01032e0:	6a 00                	push   $0x0
  pushl $217
c01032e2:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01032e7:	e9 2e f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032ec <vector218>:
.globl vector218
vector218:
  pushl $0
c01032ec:	6a 00                	push   $0x0
  pushl $218
c01032ee:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01032f3:	e9 22 f7 ff ff       	jmp    c0102a1a <__alltraps>

c01032f8 <vector219>:
.globl vector219
vector219:
  pushl $0
c01032f8:	6a 00                	push   $0x0
  pushl $219
c01032fa:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01032ff:	e9 16 f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103304 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103304:	6a 00                	push   $0x0
  pushl $220
c0103306:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010330b:	e9 0a f7 ff ff       	jmp    c0102a1a <__alltraps>

c0103310 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103310:	6a 00                	push   $0x0
  pushl $221
c0103312:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103317:	e9 fe f6 ff ff       	jmp    c0102a1a <__alltraps>

c010331c <vector222>:
.globl vector222
vector222:
  pushl $0
c010331c:	6a 00                	push   $0x0
  pushl $222
c010331e:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103323:	e9 f2 f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103328 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103328:	6a 00                	push   $0x0
  pushl $223
c010332a:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010332f:	e9 e6 f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103334 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103334:	6a 00                	push   $0x0
  pushl $224
c0103336:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010333b:	e9 da f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103340 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103340:	6a 00                	push   $0x0
  pushl $225
c0103342:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103347:	e9 ce f6 ff ff       	jmp    c0102a1a <__alltraps>

c010334c <vector226>:
.globl vector226
vector226:
  pushl $0
c010334c:	6a 00                	push   $0x0
  pushl $226
c010334e:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103353:	e9 c2 f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103358 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103358:	6a 00                	push   $0x0
  pushl $227
c010335a:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010335f:	e9 b6 f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103364 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103364:	6a 00                	push   $0x0
  pushl $228
c0103366:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010336b:	e9 aa f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103370 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103370:	6a 00                	push   $0x0
  pushl $229
c0103372:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103377:	e9 9e f6 ff ff       	jmp    c0102a1a <__alltraps>

c010337c <vector230>:
.globl vector230
vector230:
  pushl $0
c010337c:	6a 00                	push   $0x0
  pushl $230
c010337e:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103383:	e9 92 f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103388 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103388:	6a 00                	push   $0x0
  pushl $231
c010338a:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010338f:	e9 86 f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103394 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103394:	6a 00                	push   $0x0
  pushl $232
c0103396:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010339b:	e9 7a f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033a0 <vector233>:
.globl vector233
vector233:
  pushl $0
c01033a0:	6a 00                	push   $0x0
  pushl $233
c01033a2:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01033a7:	e9 6e f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033ac <vector234>:
.globl vector234
vector234:
  pushl $0
c01033ac:	6a 00                	push   $0x0
  pushl $234
c01033ae:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01033b3:	e9 62 f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033b8 <vector235>:
.globl vector235
vector235:
  pushl $0
c01033b8:	6a 00                	push   $0x0
  pushl $235
c01033ba:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01033bf:	e9 56 f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033c4 <vector236>:
.globl vector236
vector236:
  pushl $0
c01033c4:	6a 00                	push   $0x0
  pushl $236
c01033c6:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01033cb:	e9 4a f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033d0 <vector237>:
.globl vector237
vector237:
  pushl $0
c01033d0:	6a 00                	push   $0x0
  pushl $237
c01033d2:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01033d7:	e9 3e f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033dc <vector238>:
.globl vector238
vector238:
  pushl $0
c01033dc:	6a 00                	push   $0x0
  pushl $238
c01033de:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01033e3:	e9 32 f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033e8 <vector239>:
.globl vector239
vector239:
  pushl $0
c01033e8:	6a 00                	push   $0x0
  pushl $239
c01033ea:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01033ef:	e9 26 f6 ff ff       	jmp    c0102a1a <__alltraps>

c01033f4 <vector240>:
.globl vector240
vector240:
  pushl $0
c01033f4:	6a 00                	push   $0x0
  pushl $240
c01033f6:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01033fb:	e9 1a f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103400 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103400:	6a 00                	push   $0x0
  pushl $241
c0103402:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103407:	e9 0e f6 ff ff       	jmp    c0102a1a <__alltraps>

c010340c <vector242>:
.globl vector242
vector242:
  pushl $0
c010340c:	6a 00                	push   $0x0
  pushl $242
c010340e:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103413:	e9 02 f6 ff ff       	jmp    c0102a1a <__alltraps>

c0103418 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103418:	6a 00                	push   $0x0
  pushl $243
c010341a:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010341f:	e9 f6 f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103424 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103424:	6a 00                	push   $0x0
  pushl $244
c0103426:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010342b:	e9 ea f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103430 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103430:	6a 00                	push   $0x0
  pushl $245
c0103432:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103437:	e9 de f5 ff ff       	jmp    c0102a1a <__alltraps>

c010343c <vector246>:
.globl vector246
vector246:
  pushl $0
c010343c:	6a 00                	push   $0x0
  pushl $246
c010343e:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103443:	e9 d2 f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103448 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103448:	6a 00                	push   $0x0
  pushl $247
c010344a:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010344f:	e9 c6 f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103454 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103454:	6a 00                	push   $0x0
  pushl $248
c0103456:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010345b:	e9 ba f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103460 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103460:	6a 00                	push   $0x0
  pushl $249
c0103462:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103467:	e9 ae f5 ff ff       	jmp    c0102a1a <__alltraps>

c010346c <vector250>:
.globl vector250
vector250:
  pushl $0
c010346c:	6a 00                	push   $0x0
  pushl $250
c010346e:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0103473:	e9 a2 f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103478 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103478:	6a 00                	push   $0x0
  pushl $251
c010347a:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010347f:	e9 96 f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103484 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103484:	6a 00                	push   $0x0
  pushl $252
c0103486:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010348b:	e9 8a f5 ff ff       	jmp    c0102a1a <__alltraps>

c0103490 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103490:	6a 00                	push   $0x0
  pushl $253
c0103492:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103497:	e9 7e f5 ff ff       	jmp    c0102a1a <__alltraps>

c010349c <vector254>:
.globl vector254
vector254:
  pushl $0
c010349c:	6a 00                	push   $0x0
  pushl $254
c010349e:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01034a3:	e9 72 f5 ff ff       	jmp    c0102a1a <__alltraps>

c01034a8 <vector255>:
.globl vector255
vector255:
  pushl $0
c01034a8:	6a 00                	push   $0x0
  pushl $255
c01034aa:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01034af:	e9 66 f5 ff ff       	jmp    c0102a1a <__alltraps>

c01034b4 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01034b4:	55                   	push   %ebp
c01034b5:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01034b7:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c01034bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01034c0:	29 d0                	sub    %edx,%eax
c01034c2:	c1 f8 05             	sar    $0x5,%eax
}
c01034c5:	5d                   	pop    %ebp
c01034c6:	c3                   	ret    

c01034c7 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01034c7:	55                   	push   %ebp
c01034c8:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01034ca:	ff 75 08             	pushl  0x8(%ebp)
c01034cd:	e8 e2 ff ff ff       	call   c01034b4 <page2ppn>
c01034d2:	83 c4 04             	add    $0x4,%esp
c01034d5:	c1 e0 0c             	shl    $0xc,%eax
}
c01034d8:	c9                   	leave  
c01034d9:	c3                   	ret    

c01034da <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01034da:	55                   	push   %ebp
c01034db:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01034dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01034e0:	8b 00                	mov    (%eax),%eax
}
c01034e2:	5d                   	pop    %ebp
c01034e3:	c3                   	ret    

c01034e4 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01034e4:	55                   	push   %ebp
c01034e5:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01034e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01034ea:	8b 55 0c             	mov    0xc(%ebp),%edx
c01034ed:	89 10                	mov    %edx,(%eax)
}
c01034ef:	90                   	nop
c01034f0:	5d                   	pop    %ebp
c01034f1:	c3                   	ret    

c01034f2 <default_init>:
#define free_list (free_area.free_list) //
#define nr_free (free_area.nr_free)
static void test(void);

static void default_init(void)
{
c01034f2:	55                   	push   %ebp
c01034f3:	89 e5                	mov    %esp,%ebp
c01034f5:	83 ec 10             	sub    $0x10,%esp
c01034f8:	c7 45 fc 84 3f 1a c0 	movl   $0xc01a3f84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01034ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103502:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103505:	89 50 04             	mov    %edx,0x4(%eax)
c0103508:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010350b:	8b 50 04             	mov    0x4(%eax),%edx
c010350e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103511:	89 10                	mov    %edx,(%eax)
}
c0103513:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103514:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c010351b:	00 00 00 
}
c010351e:	90                   	nop
c010351f:	c9                   	leave  
c0103520:	c3                   	ret    

c0103521 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n)
{
c0103521:	55                   	push   %ebp
c0103522:	89 e5                	mov    %esp,%ebp
c0103524:	83 ec 38             	sub    $0x38,%esp
    assert(n > 0);
c0103527:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010352b:	75 16                	jne    c0103543 <default_init_memmap+0x22>
c010352d:	68 30 be 10 c0       	push   $0xc010be30
c0103532:	68 36 be 10 c0       	push   $0xc010be36
c0103537:	6a 6f                	push   $0x6f
c0103539:	68 4b be 10 c0       	push   $0xc010be4b
c010353e:	e8 43 d8 ff ff       	call   c0100d86 <__panic>
    struct Page *p = base;
c0103543:	8b 45 08             	mov    0x8(%ebp),%eax
c0103546:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c0103549:	eb 6c                	jmp    c01035b7 <default_init_memmap+0x96>
    {
        assert(PageReserved(p));
c010354b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354e:	83 c0 04             	add    $0x4,%eax
c0103551:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103558:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010355b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010355e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103561:	0f a3 10             	bt     %edx,(%eax)
c0103564:	19 c0                	sbb    %eax,%eax
c0103566:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103569:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010356d:	0f 95 c0             	setne  %al
c0103570:	0f b6 c0             	movzbl %al,%eax
c0103573:	85 c0                	test   %eax,%eax
c0103575:	75 16                	jne    c010358d <default_init_memmap+0x6c>
c0103577:	68 61 be 10 c0       	push   $0xc010be61
c010357c:	68 36 be 10 c0       	push   $0xc010be36
c0103581:	6a 73                	push   $0x73
c0103583:	68 4b be 10 c0       	push   $0xc010be4b
c0103588:	e8 f9 d7 ff ff       	call   c0100d86 <__panic>
        p->flags = p->property = 0;
c010358d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103590:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103597:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010359a:	8b 50 08             	mov    0x8(%eax),%edx
c010359d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a0:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01035a3:	83 ec 08             	sub    $0x8,%esp
c01035a6:	6a 00                	push   $0x0
c01035a8:	ff 75 f4             	pushl  -0xc(%ebp)
c01035ab:	e8 34 ff ff ff       	call   c01034e4 <set_page_ref>
c01035b0:	83 c4 10             	add    $0x10,%esp
    for (; p != base + n; p++)
c01035b3:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01035b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035ba:	c1 e0 05             	shl    $0x5,%eax
c01035bd:	89 c2                	mov    %eax,%edx
c01035bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c2:	01 d0                	add    %edx,%eax
c01035c4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01035c7:	75 82                	jne    c010354b <default_init_memmap+0x2a>
    }
    base->property = n;
c01035c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01035cc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01035cf:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01035d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d5:	83 c0 04             	add    $0x4,%eax
c01035d8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01035df:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01035e5:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01035e8:	0f ab 10             	bts    %edx,(%eax)
}
c01035eb:	90                   	nop
    nr_free += n;
c01035ec:	8b 15 8c 3f 1a c0    	mov    0xc01a3f8c,%edx
c01035f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035f5:	01 d0                	add    %edx,%eax
c01035f7:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
    list_add_before(&free_list, &(base->page_link));
c01035fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ff:	83 c0 0c             	add    $0xc,%eax
c0103602:	c7 45 e4 84 3f 1a c0 	movl   $0xc01a3f84,-0x1c(%ebp)
c0103609:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010360c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010360f:	8b 00                	mov    (%eax),%eax
c0103611:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103614:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0103617:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010361a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010361d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103620:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103623:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103626:	89 10                	mov    %edx,(%eax)
c0103628:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010362b:	8b 10                	mov    (%eax),%edx
c010362d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103630:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103633:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103636:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103639:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010363c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010363f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103642:	89 10                	mov    %edx,(%eax)
}
c0103644:	90                   	nop
}
c0103645:	90                   	nop
}
c0103646:	90                   	nop
c0103647:	c9                   	leave  
c0103648:	c3                   	ret    

c0103649 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n)
{
c0103649:	55                   	push   %ebp
c010364a:	89 e5                	mov    %esp,%ebp
c010364c:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c010364f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103653:	75 19                	jne    c010366e <default_alloc_pages+0x25>
c0103655:	68 30 be 10 c0       	push   $0xc010be30
c010365a:	68 36 be 10 c0       	push   $0xc010be36
c010365f:	68 80 00 00 00       	push   $0x80
c0103664:	68 4b be 10 c0       	push   $0xc010be4b
c0103669:	e8 18 d7 ff ff       	call   c0100d86 <__panic>
    if (n > nr_free)
c010366e:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0103673:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103676:	76 0a                	jbe    c0103682 <default_alloc_pages+0x39>
    {
        return NULL;
c0103678:	b8 00 00 00 00       	mov    $0x0,%eax
c010367d:	e9 5e 01 00 00       	jmp    c01037e0 <default_alloc_pages+0x197>
    }
    struct Page *page = NULL;
c0103682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0103689:	c7 45 f0 84 3f 1a c0 	movl   $0xc01a3f84,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list)
c0103690:	eb 1c                	jmp    c01036ae <default_alloc_pages+0x65>
    {
        struct Page *p = le2page(le, page_link);
c0103692:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103695:	83 e8 0c             	sub    $0xc,%eax
c0103698:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n)
c010369b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010369e:	8b 40 08             	mov    0x8(%eax),%eax
c01036a1:	39 45 08             	cmp    %eax,0x8(%ebp)
c01036a4:	77 08                	ja     c01036ae <default_alloc_pages+0x65>
        {
            page = p;
c01036a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01036ac:	eb 18                	jmp    c01036c6 <default_alloc_pages+0x7d>
c01036ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c01036b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036b7:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c01036ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036bd:	81 7d f0 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x10(%ebp)
c01036c4:	75 cc                	jne    c0103692 <default_alloc_pages+0x49>
        }
    }
    if (page != NULL)
c01036c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01036ca:	0f 84 0d 01 00 00    	je     c01037dd <default_alloc_pages+0x194>
    {
        if (page->property > n)
c01036d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036d3:	8b 40 08             	mov    0x8(%eax),%eax
c01036d6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01036d9:	0f 83 aa 00 00 00    	jae    c0103789 <default_alloc_pages+0x140>
        {
            struct Page *p = page + n;
c01036df:	8b 45 08             	mov    0x8(%ebp),%eax
c01036e2:	c1 e0 05             	shl    $0x5,%eax
c01036e5:	89 c2                	mov    %eax,%edx
c01036e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036ea:	01 d0                	add    %edx,%eax
c01036ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c01036ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f2:	8b 40 08             	mov    0x8(%eax),%eax
c01036f5:	2b 45 08             	sub    0x8(%ebp),%eax
c01036f8:	89 c2                	mov    %eax,%edx
c01036fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01036fd:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0103700:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103703:	83 c0 0c             	add    $0xc,%eax
c0103706:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103709:	83 c2 0c             	add    $0xc,%edx
c010370c:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010370f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103712:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103715:	8b 40 04             	mov    0x4(%eax),%eax
c0103718:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010371b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c010371e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103721:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0103724:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
c0103727:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010372a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010372d:	89 10                	mov    %edx,(%eax)
c010372f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103732:	8b 10                	mov    (%eax),%edx
c0103734:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103737:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010373a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010373d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103740:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103743:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103746:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103749:	89 10                	mov    %edx,(%eax)
}
c010374b:	90                   	nop
}
c010374c:	90                   	nop
            //---------------------------------
            PageReserved(page);
c010374d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103750:	83 c0 04             	add    $0x4,%eax
c0103753:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
c010375a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010375d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103760:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103763:	0f a3 10             	bt     %edx,(%eax)
c0103766:	19 c0                	sbb    %eax,%eax
c0103768:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c010376b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
            SetPageProperty(p);
c010376f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103772:	83 c0 04             	add    $0x4,%eax
c0103775:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010377c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010377f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103782:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103785:	0f ab 10             	bts    %edx,(%eax)
}
c0103788:	90                   	nop
            //---------------------------------
        }
        list_del(&(page->page_link));
c0103789:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010378c:	83 c0 0c             	add    $0xc,%eax
c010378f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103792:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103795:	8b 40 04             	mov    0x4(%eax),%eax
c0103798:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010379b:	8b 12                	mov    (%edx),%edx
c010379d:	89 55 ac             	mov    %edx,-0x54(%ebp)
c01037a0:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01037a3:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01037a6:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01037a9:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01037ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01037af:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01037b2:	89 10                	mov    %edx,(%eax)
}
c01037b4:	90                   	nop
}
c01037b5:	90                   	nop
        nr_free -= n;
c01037b6:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c01037bb:	2b 45 08             	sub    0x8(%ebp),%eax
c01037be:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
        ClearPageProperty(page);
c01037c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037c6:	83 c0 04             	add    $0x4,%eax
c01037c9:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01037d0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037d3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01037d6:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01037d9:	0f b3 10             	btr    %edx,(%eax)
}
c01037dc:	90                   	nop
    }
    return page;
c01037dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01037e0:	c9                   	leave  
c01037e1:	c3                   	ret    

c01037e2 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n)
{
c01037e2:	55                   	push   %ebp
c01037e3:	89 e5                	mov    %esp,%ebp
c01037e5:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c01037eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01037ef:	75 19                	jne    c010380a <default_free_pages+0x28>
c01037f1:	68 30 be 10 c0       	push   $0xc010be30
c01037f6:	68 36 be 10 c0       	push   $0xc010be36
c01037fb:	68 a6 00 00 00       	push   $0xa6
c0103800:	68 4b be 10 c0       	push   $0xc010be4b
c0103805:	e8 7c d5 ff ff       	call   c0100d86 <__panic>
    struct Page *p = base;
c010380a:	8b 45 08             	mov    0x8(%ebp),%eax
c010380d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c0103810:	e9 8f 00 00 00       	jmp    c01038a4 <default_free_pages+0xc2>
    {
        assert(!PageReserved(p) && !PageProperty(p));
c0103815:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103818:	83 c0 04             	add    $0x4,%eax
c010381b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0103822:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103825:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103828:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010382b:	0f a3 10             	bt     %edx,(%eax)
c010382e:	19 c0                	sbb    %eax,%eax
c0103830:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
c0103833:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103837:	0f 95 c0             	setne  %al
c010383a:	0f b6 c0             	movzbl %al,%eax
c010383d:	85 c0                	test   %eax,%eax
c010383f:	75 2c                	jne    c010386d <default_free_pages+0x8b>
c0103841:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103844:	83 c0 04             	add    $0x4,%eax
c0103847:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c010384e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103851:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103854:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103857:	0f a3 10             	bt     %edx,(%eax)
c010385a:	19 c0                	sbb    %eax,%eax
c010385c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c010385f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0103863:	0f 95 c0             	setne  %al
c0103866:	0f b6 c0             	movzbl %al,%eax
c0103869:	85 c0                	test   %eax,%eax
c010386b:	74 19                	je     c0103886 <default_free_pages+0xa4>
c010386d:	68 74 be 10 c0       	push   $0xc010be74
c0103872:	68 36 be 10 c0       	push   $0xc010be36
c0103877:	68 aa 00 00 00       	push   $0xaa
c010387c:	68 4b be 10 c0       	push   $0xc010be4b
c0103881:	e8 00 d5 ff ff       	call   c0100d86 <__panic>
        p->flags = 0;
c0103886:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103889:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103890:	83 ec 08             	sub    $0x8,%esp
c0103893:	6a 00                	push   $0x0
c0103895:	ff 75 f4             	pushl  -0xc(%ebp)
c0103898:	e8 47 fc ff ff       	call   c01034e4 <set_page_ref>
c010389d:	83 c4 10             	add    $0x10,%esp
    for (; p != base + n; p++)
c01038a0:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01038a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038a7:	c1 e0 05             	shl    $0x5,%eax
c01038aa:	89 c2                	mov    %eax,%edx
c01038ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01038af:	01 d0                	add    %edx,%eax
c01038b1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01038b4:	0f 85 5b ff ff ff    	jne    c0103815 <default_free_pages+0x33>
    }
    base->property = n;
c01038ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01038bd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01038c0:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01038c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c6:	83 c0 04             	add    $0x4,%eax
c01038c9:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01038d0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01038d3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01038d6:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01038d9:	0f ab 10             	bts    %edx,(%eax)
}
c01038dc:	90                   	nop
c01038dd:	c7 45 cc 84 3f 1a c0 	movl   $0xc01a3f84,-0x34(%ebp)
    return listelm->next;
c01038e4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01038e7:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list), *sp = NULL;
c01038ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    bool flag = 0;
c01038f4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while (le != &free_list)
c01038fb:	e9 39 01 00 00       	jmp    c0103a39 <default_free_pages+0x257>
    {
        // sp = le;
        p = le2page(le, page_link);
c0103900:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103903:	83 e8 0c             	sub    $0xc,%eax
c0103906:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property == p)
c0103909:	8b 45 08             	mov    0x8(%ebp),%eax
c010390c:	8b 40 08             	mov    0x8(%eax),%eax
c010390f:	c1 e0 05             	shl    $0x5,%eax
c0103912:	89 c2                	mov    %eax,%edx
c0103914:	8b 45 08             	mov    0x8(%ebp),%eax
c0103917:	01 d0                	add    %edx,%eax
c0103919:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010391c:	75 5f                	jne    c010397d <default_free_pages+0x19b>
        {
            base->property += p->property;
c010391e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103921:	8b 50 08             	mov    0x8(%eax),%edx
c0103924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103927:	8b 40 08             	mov    0x8(%eax),%eax
c010392a:	01 c2                	add    %eax,%edx
c010392c:	8b 45 08             	mov    0x8(%ebp),%eax
c010392f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103932:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103935:	83 c0 04             	add    $0x4,%eax
c0103938:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c010393f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103942:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103945:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103948:	0f b3 10             	btr    %edx,(%eax)
}
c010394b:	90                   	nop
            list_del(&(p->page_link));
c010394c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010394f:	83 c0 0c             	add    $0xc,%eax
c0103952:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103955:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103958:	8b 40 04             	mov    0x4(%eax),%eax
c010395b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010395e:	8b 12                	mov    (%edx),%edx
c0103960:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103963:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
c0103966:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103969:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010396c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010396f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103972:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103975:	89 10                	mov    %edx,(%eax)
}
c0103977:	90                   	nop
}
c0103978:	e9 8b 00 00 00       	jmp    c0103a08 <default_free_pages+0x226>
        }
        else if (p + p->property == base)
c010397d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103980:	8b 40 08             	mov    0x8(%eax),%eax
c0103983:	c1 e0 05             	shl    $0x5,%eax
c0103986:	89 c2                	mov    %eax,%edx
c0103988:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010398b:	01 d0                	add    %edx,%eax
c010398d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103990:	75 76                	jne    c0103a08 <default_free_pages+0x226>
        {
            p->property += base->property;
c0103992:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103995:	8b 50 08             	mov    0x8(%eax),%edx
c0103998:	8b 45 08             	mov    0x8(%ebp),%eax
c010399b:	8b 40 08             	mov    0x8(%eax),%eax
c010399e:	01 c2                	add    %eax,%edx
c01039a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039a3:	89 50 08             	mov    %edx,0x8(%eax)
c01039a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039a9:	89 45 98             	mov    %eax,-0x68(%ebp)
    return listelm->prev;
c01039ac:	8b 45 98             	mov    -0x68(%ebp),%eax
c01039af:	8b 00                	mov    (%eax),%eax
            sp = list_prev(le);
c01039b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
            flag = 1;
c01039b4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
            ClearPageProperty(base);
c01039bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01039be:	83 c0 04             	add    $0x4,%eax
c01039c1:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01039c8:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01039cb:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01039ce:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01039d1:	0f b3 10             	btr    %edx,(%eax)
}
c01039d4:	90                   	nop
            base = p;
c01039d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039d8:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01039db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039de:	83 c0 0c             	add    $0xc,%eax
c01039e1:	89 45 ac             	mov    %eax,-0x54(%ebp)
    __list_del(listelm->prev, listelm->next);
c01039e4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01039e7:	8b 40 04             	mov    0x4(%eax),%eax
c01039ea:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01039ed:	8b 12                	mov    (%edx),%edx
c01039ef:	89 55 a8             	mov    %edx,-0x58(%ebp)
c01039f2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    prev->next = next;
c01039f5:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01039f8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01039fb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01039fe:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103a01:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103a04:	89 10                	mov    %edx,(%eax)
}
c0103a06:	90                   	nop
}
c0103a07:	90                   	nop
        }
        if (p + p->property < base)
c0103a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a0b:	8b 40 08             	mov    0x8(%eax),%eax
c0103a0e:	c1 e0 05             	shl    $0x5,%eax
c0103a11:	89 c2                	mov    %eax,%edx
c0103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a16:	01 d0                	add    %edx,%eax
c0103a18:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103a1b:	76 0d                	jbe    c0103a2a <default_free_pages+0x248>
            sp = le, flag = 1;
c0103a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a20:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a23:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0103a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a2d:	89 45 94             	mov    %eax,-0x6c(%ebp)
    return listelm->next;
c0103a30:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103a33:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103a36:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c0103a39:	81 7d f0 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x10(%ebp)
c0103a40:	0f 85 ba fe ff ff    	jne    c0103900 <default_free_pages+0x11e>
    }
    nr_free += n;
c0103a46:	8b 15 8c 3f 1a c0    	mov    0xc01a3f8c,%edx
c0103a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a4f:	01 d0                	add    %edx,%eax
c0103a51:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
    //cprintf("%x %x\n", sp, &free_list);
    list_add((flag ? sp : &free_list), &(base->page_link));
c0103a56:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a59:	8d 50 0c             	lea    0xc(%eax),%edx
c0103a5c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103a60:	74 05                	je     c0103a67 <default_free_pages+0x285>
c0103a62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a65:	eb 05                	jmp    c0103a6c <default_free_pages+0x28a>
c0103a67:	b8 84 3f 1a c0       	mov    $0xc01a3f84,%eax
c0103a6c:	89 45 90             	mov    %eax,-0x70(%ebp)
c0103a6f:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103a72:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103a75:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103a78:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103a7b:	89 45 84             	mov    %eax,-0x7c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103a7e:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103a81:	8b 40 04             	mov    0x4(%eax),%eax
c0103a84:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103a87:	89 55 80             	mov    %edx,-0x80(%ebp)
c0103a8a:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103a8d:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103a93:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    prev->next = next->prev = elm;
c0103a99:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103a9f:	8b 55 80             	mov    -0x80(%ebp),%edx
c0103aa2:	89 10                	mov    %edx,(%eax)
c0103aa4:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103aaa:	8b 10                	mov    (%eax),%edx
c0103aac:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103ab2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103ab5:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103ab8:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
c0103abe:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103ac1:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103ac4:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103aca:	89 10                	mov    %edx,(%eax)
}
c0103acc:	90                   	nop
}
c0103acd:	90                   	nop
}
c0103ace:	90                   	nop
}
c0103acf:	90                   	nop
c0103ad0:	c9                   	leave  
c0103ad1:	c3                   	ret    

c0103ad2 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
c0103ad2:	55                   	push   %ebp
c0103ad3:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103ad5:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
}
c0103ada:	5d                   	pop    %ebp
c0103adb:	c3                   	ret    

c0103adc <basic_check>:

static void
basic_check(void)
{
c0103adc:	55                   	push   %ebp
c0103add:	89 e5                	mov    %esp,%ebp
c0103adf:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103af2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103af5:	83 ec 0c             	sub    $0xc,%esp
c0103af8:	6a 01                	push   $0x1
c0103afa:	e8 a4 14 00 00       	call   c0104fa3 <alloc_pages>
c0103aff:	83 c4 10             	add    $0x10,%esp
c0103b02:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b05:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103b09:	75 19                	jne    c0103b24 <basic_check+0x48>
c0103b0b:	68 99 be 10 c0       	push   $0xc010be99
c0103b10:	68 36 be 10 c0       	push   $0xc010be36
c0103b15:	68 d9 00 00 00       	push   $0xd9
c0103b1a:	68 4b be 10 c0       	push   $0xc010be4b
c0103b1f:	e8 62 d2 ff ff       	call   c0100d86 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103b24:	83 ec 0c             	sub    $0xc,%esp
c0103b27:	6a 01                	push   $0x1
c0103b29:	e8 75 14 00 00       	call   c0104fa3 <alloc_pages>
c0103b2e:	83 c4 10             	add    $0x10,%esp
c0103b31:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103b38:	75 19                	jne    c0103b53 <basic_check+0x77>
c0103b3a:	68 b5 be 10 c0       	push   $0xc010beb5
c0103b3f:	68 36 be 10 c0       	push   $0xc010be36
c0103b44:	68 da 00 00 00       	push   $0xda
c0103b49:	68 4b be 10 c0       	push   $0xc010be4b
c0103b4e:	e8 33 d2 ff ff       	call   c0100d86 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103b53:	83 ec 0c             	sub    $0xc,%esp
c0103b56:	6a 01                	push   $0x1
c0103b58:	e8 46 14 00 00       	call   c0104fa3 <alloc_pages>
c0103b5d:	83 c4 10             	add    $0x10,%esp
c0103b60:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b67:	75 19                	jne    c0103b82 <basic_check+0xa6>
c0103b69:	68 d1 be 10 c0       	push   $0xc010bed1
c0103b6e:	68 36 be 10 c0       	push   $0xc010be36
c0103b73:	68 db 00 00 00       	push   $0xdb
c0103b78:	68 4b be 10 c0       	push   $0xc010be4b
c0103b7d:	e8 04 d2 ff ff       	call   c0100d86 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103b82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b85:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103b88:	74 10                	je     c0103b9a <basic_check+0xbe>
c0103b8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b8d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b90:	74 08                	je     c0103b9a <basic_check+0xbe>
c0103b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b95:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103b98:	75 19                	jne    c0103bb3 <basic_check+0xd7>
c0103b9a:	68 f0 be 10 c0       	push   $0xc010bef0
c0103b9f:	68 36 be 10 c0       	push   $0xc010be36
c0103ba4:	68 dd 00 00 00       	push   $0xdd
c0103ba9:	68 4b be 10 c0       	push   $0xc010be4b
c0103bae:	e8 d3 d1 ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103bb3:	83 ec 0c             	sub    $0xc,%esp
c0103bb6:	ff 75 ec             	pushl  -0x14(%ebp)
c0103bb9:	e8 1c f9 ff ff       	call   c01034da <page_ref>
c0103bbe:	83 c4 10             	add    $0x10,%esp
c0103bc1:	85 c0                	test   %eax,%eax
c0103bc3:	75 24                	jne    c0103be9 <basic_check+0x10d>
c0103bc5:	83 ec 0c             	sub    $0xc,%esp
c0103bc8:	ff 75 f0             	pushl  -0x10(%ebp)
c0103bcb:	e8 0a f9 ff ff       	call   c01034da <page_ref>
c0103bd0:	83 c4 10             	add    $0x10,%esp
c0103bd3:	85 c0                	test   %eax,%eax
c0103bd5:	75 12                	jne    c0103be9 <basic_check+0x10d>
c0103bd7:	83 ec 0c             	sub    $0xc,%esp
c0103bda:	ff 75 f4             	pushl  -0xc(%ebp)
c0103bdd:	e8 f8 f8 ff ff       	call   c01034da <page_ref>
c0103be2:	83 c4 10             	add    $0x10,%esp
c0103be5:	85 c0                	test   %eax,%eax
c0103be7:	74 19                	je     c0103c02 <basic_check+0x126>
c0103be9:	68 14 bf 10 c0       	push   $0xc010bf14
c0103bee:	68 36 be 10 c0       	push   $0xc010be36
c0103bf3:	68 de 00 00 00       	push   $0xde
c0103bf8:	68 4b be 10 c0       	push   $0xc010be4b
c0103bfd:	e8 84 d1 ff ff       	call   c0100d86 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103c02:	83 ec 0c             	sub    $0xc,%esp
c0103c05:	ff 75 ec             	pushl  -0x14(%ebp)
c0103c08:	e8 ba f8 ff ff       	call   c01034c7 <page2pa>
c0103c0d:	83 c4 10             	add    $0x10,%esp
c0103c10:	8b 15 a4 3f 1a c0    	mov    0xc01a3fa4,%edx
c0103c16:	c1 e2 0c             	shl    $0xc,%edx
c0103c19:	39 d0                	cmp    %edx,%eax
c0103c1b:	72 19                	jb     c0103c36 <basic_check+0x15a>
c0103c1d:	68 50 bf 10 c0       	push   $0xc010bf50
c0103c22:	68 36 be 10 c0       	push   $0xc010be36
c0103c27:	68 e0 00 00 00       	push   $0xe0
c0103c2c:	68 4b be 10 c0       	push   $0xc010be4b
c0103c31:	e8 50 d1 ff ff       	call   c0100d86 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103c36:	83 ec 0c             	sub    $0xc,%esp
c0103c39:	ff 75 f0             	pushl  -0x10(%ebp)
c0103c3c:	e8 86 f8 ff ff       	call   c01034c7 <page2pa>
c0103c41:	83 c4 10             	add    $0x10,%esp
c0103c44:	8b 15 a4 3f 1a c0    	mov    0xc01a3fa4,%edx
c0103c4a:	c1 e2 0c             	shl    $0xc,%edx
c0103c4d:	39 d0                	cmp    %edx,%eax
c0103c4f:	72 19                	jb     c0103c6a <basic_check+0x18e>
c0103c51:	68 6d bf 10 c0       	push   $0xc010bf6d
c0103c56:	68 36 be 10 c0       	push   $0xc010be36
c0103c5b:	68 e1 00 00 00       	push   $0xe1
c0103c60:	68 4b be 10 c0       	push   $0xc010be4b
c0103c65:	e8 1c d1 ff ff       	call   c0100d86 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103c6a:	83 ec 0c             	sub    $0xc,%esp
c0103c6d:	ff 75 f4             	pushl  -0xc(%ebp)
c0103c70:	e8 52 f8 ff ff       	call   c01034c7 <page2pa>
c0103c75:	83 c4 10             	add    $0x10,%esp
c0103c78:	8b 15 a4 3f 1a c0    	mov    0xc01a3fa4,%edx
c0103c7e:	c1 e2 0c             	shl    $0xc,%edx
c0103c81:	39 d0                	cmp    %edx,%eax
c0103c83:	72 19                	jb     c0103c9e <basic_check+0x1c2>
c0103c85:	68 8a bf 10 c0       	push   $0xc010bf8a
c0103c8a:	68 36 be 10 c0       	push   $0xc010be36
c0103c8f:	68 e2 00 00 00       	push   $0xe2
c0103c94:	68 4b be 10 c0       	push   $0xc010be4b
c0103c99:	e8 e8 d0 ff ff       	call   c0100d86 <__panic>

    list_entry_t free_list_store = free_list;
c0103c9e:	a1 84 3f 1a c0       	mov    0xc01a3f84,%eax
c0103ca3:	8b 15 88 3f 1a c0    	mov    0xc01a3f88,%edx
c0103ca9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103cac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103caf:	c7 45 dc 84 3f 1a c0 	movl   $0xc01a3f84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103cb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cb9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103cbc:	89 50 04             	mov    %edx,0x4(%eax)
c0103cbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cc2:	8b 50 04             	mov    0x4(%eax),%edx
c0103cc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cc8:	89 10                	mov    %edx,(%eax)
}
c0103cca:	90                   	nop
c0103ccb:	c7 45 e0 84 3f 1a c0 	movl   $0xc01a3f84,-0x20(%ebp)
    return list->next == list;
c0103cd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103cd5:	8b 40 04             	mov    0x4(%eax),%eax
c0103cd8:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103cdb:	0f 94 c0             	sete   %al
c0103cde:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103ce1:	85 c0                	test   %eax,%eax
c0103ce3:	75 19                	jne    c0103cfe <basic_check+0x222>
c0103ce5:	68 a7 bf 10 c0       	push   $0xc010bfa7
c0103cea:	68 36 be 10 c0       	push   $0xc010be36
c0103cef:	68 e6 00 00 00       	push   $0xe6
c0103cf4:	68 4b be 10 c0       	push   $0xc010be4b
c0103cf9:	e8 88 d0 ff ff       	call   c0100d86 <__panic>

    unsigned int nr_free_store = nr_free;
c0103cfe:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0103d03:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103d06:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c0103d0d:	00 00 00 

    assert(alloc_page() == NULL);
c0103d10:	83 ec 0c             	sub    $0xc,%esp
c0103d13:	6a 01                	push   $0x1
c0103d15:	e8 89 12 00 00       	call   c0104fa3 <alloc_pages>
c0103d1a:	83 c4 10             	add    $0x10,%esp
c0103d1d:	85 c0                	test   %eax,%eax
c0103d1f:	74 19                	je     c0103d3a <basic_check+0x25e>
c0103d21:	68 be bf 10 c0       	push   $0xc010bfbe
c0103d26:	68 36 be 10 c0       	push   $0xc010be36
c0103d2b:	68 eb 00 00 00       	push   $0xeb
c0103d30:	68 4b be 10 c0       	push   $0xc010be4b
c0103d35:	e8 4c d0 ff ff       	call   c0100d86 <__panic>

    free_page(p0);
c0103d3a:	83 ec 08             	sub    $0x8,%esp
c0103d3d:	6a 01                	push   $0x1
c0103d3f:	ff 75 ec             	pushl  -0x14(%ebp)
c0103d42:	e8 c8 12 00 00       	call   c010500f <free_pages>
c0103d47:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0103d4a:	83 ec 08             	sub    $0x8,%esp
c0103d4d:	6a 01                	push   $0x1
c0103d4f:	ff 75 f0             	pushl  -0x10(%ebp)
c0103d52:	e8 b8 12 00 00       	call   c010500f <free_pages>
c0103d57:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0103d5a:	83 ec 08             	sub    $0x8,%esp
c0103d5d:	6a 01                	push   $0x1
c0103d5f:	ff 75 f4             	pushl  -0xc(%ebp)
c0103d62:	e8 a8 12 00 00       	call   c010500f <free_pages>
c0103d67:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c0103d6a:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0103d6f:	83 f8 03             	cmp    $0x3,%eax
c0103d72:	74 19                	je     c0103d8d <basic_check+0x2b1>
c0103d74:	68 d3 bf 10 c0       	push   $0xc010bfd3
c0103d79:	68 36 be 10 c0       	push   $0xc010be36
c0103d7e:	68 f0 00 00 00       	push   $0xf0
c0103d83:	68 4b be 10 c0       	push   $0xc010be4b
c0103d88:	e8 f9 cf ff ff       	call   c0100d86 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103d8d:	83 ec 0c             	sub    $0xc,%esp
c0103d90:	6a 01                	push   $0x1
c0103d92:	e8 0c 12 00 00       	call   c0104fa3 <alloc_pages>
c0103d97:	83 c4 10             	add    $0x10,%esp
c0103d9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d9d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103da1:	75 19                	jne    c0103dbc <basic_check+0x2e0>
c0103da3:	68 99 be 10 c0       	push   $0xc010be99
c0103da8:	68 36 be 10 c0       	push   $0xc010be36
c0103dad:	68 f2 00 00 00       	push   $0xf2
c0103db2:	68 4b be 10 c0       	push   $0xc010be4b
c0103db7:	e8 ca cf ff ff       	call   c0100d86 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103dbc:	83 ec 0c             	sub    $0xc,%esp
c0103dbf:	6a 01                	push   $0x1
c0103dc1:	e8 dd 11 00 00       	call   c0104fa3 <alloc_pages>
c0103dc6:	83 c4 10             	add    $0x10,%esp
c0103dc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103dcc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103dd0:	75 19                	jne    c0103deb <basic_check+0x30f>
c0103dd2:	68 b5 be 10 c0       	push   $0xc010beb5
c0103dd7:	68 36 be 10 c0       	push   $0xc010be36
c0103ddc:	68 f3 00 00 00       	push   $0xf3
c0103de1:	68 4b be 10 c0       	push   $0xc010be4b
c0103de6:	e8 9b cf ff ff       	call   c0100d86 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103deb:	83 ec 0c             	sub    $0xc,%esp
c0103dee:	6a 01                	push   $0x1
c0103df0:	e8 ae 11 00 00       	call   c0104fa3 <alloc_pages>
c0103df5:	83 c4 10             	add    $0x10,%esp
c0103df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103dfb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103dff:	75 19                	jne    c0103e1a <basic_check+0x33e>
c0103e01:	68 d1 be 10 c0       	push   $0xc010bed1
c0103e06:	68 36 be 10 c0       	push   $0xc010be36
c0103e0b:	68 f4 00 00 00       	push   $0xf4
c0103e10:	68 4b be 10 c0       	push   $0xc010be4b
c0103e15:	e8 6c cf ff ff       	call   c0100d86 <__panic>

    assert(alloc_page() == NULL);
c0103e1a:	83 ec 0c             	sub    $0xc,%esp
c0103e1d:	6a 01                	push   $0x1
c0103e1f:	e8 7f 11 00 00       	call   c0104fa3 <alloc_pages>
c0103e24:	83 c4 10             	add    $0x10,%esp
c0103e27:	85 c0                	test   %eax,%eax
c0103e29:	74 19                	je     c0103e44 <basic_check+0x368>
c0103e2b:	68 be bf 10 c0       	push   $0xc010bfbe
c0103e30:	68 36 be 10 c0       	push   $0xc010be36
c0103e35:	68 f6 00 00 00       	push   $0xf6
c0103e3a:	68 4b be 10 c0       	push   $0xc010be4b
c0103e3f:	e8 42 cf ff ff       	call   c0100d86 <__panic>

    free_page(p0);
c0103e44:	83 ec 08             	sub    $0x8,%esp
c0103e47:	6a 01                	push   $0x1
c0103e49:	ff 75 ec             	pushl  -0x14(%ebp)
c0103e4c:	e8 be 11 00 00       	call   c010500f <free_pages>
c0103e51:	83 c4 10             	add    $0x10,%esp
c0103e54:	c7 45 d8 84 3f 1a c0 	movl   $0xc01a3f84,-0x28(%ebp)
c0103e5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e5e:	8b 40 04             	mov    0x4(%eax),%eax
c0103e61:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103e64:	0f 94 c0             	sete   %al
c0103e67:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103e6a:	85 c0                	test   %eax,%eax
c0103e6c:	74 19                	je     c0103e87 <basic_check+0x3ab>
c0103e6e:	68 e0 bf 10 c0       	push   $0xc010bfe0
c0103e73:	68 36 be 10 c0       	push   $0xc010be36
c0103e78:	68 f9 00 00 00       	push   $0xf9
c0103e7d:	68 4b be 10 c0       	push   $0xc010be4b
c0103e82:	e8 ff ce ff ff       	call   c0100d86 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103e87:	83 ec 0c             	sub    $0xc,%esp
c0103e8a:	6a 01                	push   $0x1
c0103e8c:	e8 12 11 00 00       	call   c0104fa3 <alloc_pages>
c0103e91:	83 c4 10             	add    $0x10,%esp
c0103e94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e9a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103e9d:	74 19                	je     c0103eb8 <basic_check+0x3dc>
c0103e9f:	68 f8 bf 10 c0       	push   $0xc010bff8
c0103ea4:	68 36 be 10 c0       	push   $0xc010be36
c0103ea9:	68 fc 00 00 00       	push   $0xfc
c0103eae:	68 4b be 10 c0       	push   $0xc010be4b
c0103eb3:	e8 ce ce ff ff       	call   c0100d86 <__panic>
    assert(alloc_page() == NULL);
c0103eb8:	83 ec 0c             	sub    $0xc,%esp
c0103ebb:	6a 01                	push   $0x1
c0103ebd:	e8 e1 10 00 00       	call   c0104fa3 <alloc_pages>
c0103ec2:	83 c4 10             	add    $0x10,%esp
c0103ec5:	85 c0                	test   %eax,%eax
c0103ec7:	74 19                	je     c0103ee2 <basic_check+0x406>
c0103ec9:	68 be bf 10 c0       	push   $0xc010bfbe
c0103ece:	68 36 be 10 c0       	push   $0xc010be36
c0103ed3:	68 fd 00 00 00       	push   $0xfd
c0103ed8:	68 4b be 10 c0       	push   $0xc010be4b
c0103edd:	e8 a4 ce ff ff       	call   c0100d86 <__panic>

    assert(nr_free == 0);
c0103ee2:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0103ee7:	85 c0                	test   %eax,%eax
c0103ee9:	74 19                	je     c0103f04 <basic_check+0x428>
c0103eeb:	68 11 c0 10 c0       	push   $0xc010c011
c0103ef0:	68 36 be 10 c0       	push   $0xc010be36
c0103ef5:	68 ff 00 00 00       	push   $0xff
c0103efa:	68 4b be 10 c0       	push   $0xc010be4b
c0103eff:	e8 82 ce ff ff       	call   c0100d86 <__panic>
    free_list = free_list_store;
c0103f04:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103f07:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f0a:	a3 84 3f 1a c0       	mov    %eax,0xc01a3f84
c0103f0f:	89 15 88 3f 1a c0    	mov    %edx,0xc01a3f88
    nr_free = nr_free_store;
c0103f15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f18:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c

    free_page(p);
c0103f1d:	83 ec 08             	sub    $0x8,%esp
c0103f20:	6a 01                	push   $0x1
c0103f22:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103f25:	e8 e5 10 00 00       	call   c010500f <free_pages>
c0103f2a:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0103f2d:	83 ec 08             	sub    $0x8,%esp
c0103f30:	6a 01                	push   $0x1
c0103f32:	ff 75 f0             	pushl  -0x10(%ebp)
c0103f35:	e8 d5 10 00 00       	call   c010500f <free_pages>
c0103f3a:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0103f3d:	83 ec 08             	sub    $0x8,%esp
c0103f40:	6a 01                	push   $0x1
c0103f42:	ff 75 f4             	pushl  -0xc(%ebp)
c0103f45:	e8 c5 10 00 00       	call   c010500f <free_pages>
c0103f4a:	83 c4 10             	add    $0x10,%esp
}
c0103f4d:	90                   	nop
c0103f4e:	c9                   	leave  
c0103f4f:	c3                   	ret    

c0103f50 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
c0103f50:	55                   	push   %ebp
c0103f51:	89 e5                	mov    %esp,%ebp
c0103f53:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c0103f59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103f67:	c7 45 ec 84 3f 1a c0 	movl   $0xc01a3f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c0103f6e:	eb 60                	jmp    c0103fd0 <default_check+0x80>
    {
        struct Page *p = le2page(le, page_link);
c0103f70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f73:	83 e8 0c             	sub    $0xc,%eax
c0103f76:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103f79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f7c:	83 c0 04             	add    $0x4,%eax
c0103f7f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103f86:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f89:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103f8c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103f8f:	0f a3 10             	bt     %edx,(%eax)
c0103f92:	19 c0                	sbb    %eax,%eax
c0103f94:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103f97:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103f9b:	0f 95 c0             	setne  %al
c0103f9e:	0f b6 c0             	movzbl %al,%eax
c0103fa1:	85 c0                	test   %eax,%eax
c0103fa3:	75 19                	jne    c0103fbe <default_check+0x6e>
c0103fa5:	68 1e c0 10 c0       	push   $0xc010c01e
c0103faa:	68 36 be 10 c0       	push   $0xc010be36
c0103faf:	68 12 01 00 00       	push   $0x112
c0103fb4:	68 4b be 10 c0       	push   $0xc010be4b
c0103fb9:	e8 c8 cd ff ff       	call   c0100d86 <__panic>
        count++, total += p->property;
c0103fbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103fc2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103fc5:	8b 50 08             	mov    0x8(%eax),%edx
c0103fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fcb:	01 d0                	add    %edx,%eax
c0103fcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fd3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0103fd6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103fd9:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c0103fdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103fdf:	81 7d ec 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x14(%ebp)
c0103fe6:	75 88                	jne    c0103f70 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0103fe8:	e8 57 10 00 00       	call   c0105044 <nr_free_pages>
c0103fed:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103ff0:	39 d0                	cmp    %edx,%eax
c0103ff2:	74 19                	je     c010400d <default_check+0xbd>
c0103ff4:	68 2e c0 10 c0       	push   $0xc010c02e
c0103ff9:	68 36 be 10 c0       	push   $0xc010be36
c0103ffe:	68 15 01 00 00       	push   $0x115
c0104003:	68 4b be 10 c0       	push   $0xc010be4b
c0104008:	e8 79 cd ff ff       	call   c0100d86 <__panic>

    basic_check();
c010400d:	e8 ca fa ff ff       	call   c0103adc <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104012:	83 ec 0c             	sub    $0xc,%esp
c0104015:	6a 05                	push   $0x5
c0104017:	e8 87 0f 00 00       	call   c0104fa3 <alloc_pages>
c010401c:	83 c4 10             	add    $0x10,%esp
c010401f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104022:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104026:	75 19                	jne    c0104041 <default_check+0xf1>
c0104028:	68 47 c0 10 c0       	push   $0xc010c047
c010402d:	68 36 be 10 c0       	push   $0xc010be36
c0104032:	68 1a 01 00 00       	push   $0x11a
c0104037:	68 4b be 10 c0       	push   $0xc010be4b
c010403c:	e8 45 cd ff ff       	call   c0100d86 <__panic>
    assert(!PageProperty(p0));
c0104041:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104044:	83 c0 04             	add    $0x4,%eax
c0104047:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010404e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104051:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104054:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104057:	0f a3 10             	bt     %edx,(%eax)
c010405a:	19 c0                	sbb    %eax,%eax
c010405c:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010405f:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104063:	0f 95 c0             	setne  %al
c0104066:	0f b6 c0             	movzbl %al,%eax
c0104069:	85 c0                	test   %eax,%eax
c010406b:	74 19                	je     c0104086 <default_check+0x136>
c010406d:	68 52 c0 10 c0       	push   $0xc010c052
c0104072:	68 36 be 10 c0       	push   $0xc010be36
c0104077:	68 1b 01 00 00       	push   $0x11b
c010407c:	68 4b be 10 c0       	push   $0xc010be4b
c0104081:	e8 00 cd ff ff       	call   c0100d86 <__panic>

    // simualte the situation that all memory is used
    list_entry_t free_list_store = free_list;
c0104086:	a1 84 3f 1a c0       	mov    0xc01a3f84,%eax
c010408b:	8b 15 88 3f 1a c0    	mov    0xc01a3f88,%edx
c0104091:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104094:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104097:	c7 45 b0 84 3f 1a c0 	movl   $0xc01a3f84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c010409e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040a1:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01040a4:	89 50 04             	mov    %edx,0x4(%eax)
c01040a7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040aa:	8b 50 04             	mov    0x4(%eax),%edx
c01040ad:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040b0:	89 10                	mov    %edx,(%eax)
}
c01040b2:	90                   	nop
c01040b3:	c7 45 b4 84 3f 1a c0 	movl   $0xc01a3f84,-0x4c(%ebp)
    return list->next == list;
c01040ba:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01040bd:	8b 40 04             	mov    0x4(%eax),%eax
c01040c0:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c01040c3:	0f 94 c0             	sete   %al
c01040c6:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01040c9:	85 c0                	test   %eax,%eax
c01040cb:	75 19                	jne    c01040e6 <default_check+0x196>
c01040cd:	68 a7 bf 10 c0       	push   $0xc010bfa7
c01040d2:	68 36 be 10 c0       	push   $0xc010be36
c01040d7:	68 20 01 00 00       	push   $0x120
c01040dc:	68 4b be 10 c0       	push   $0xc010be4b
c01040e1:	e8 a0 cc ff ff       	call   c0100d86 <__panic>
    assert(alloc_page() == NULL);
c01040e6:	83 ec 0c             	sub    $0xc,%esp
c01040e9:	6a 01                	push   $0x1
c01040eb:	e8 b3 0e 00 00       	call   c0104fa3 <alloc_pages>
c01040f0:	83 c4 10             	add    $0x10,%esp
c01040f3:	85 c0                	test   %eax,%eax
c01040f5:	74 19                	je     c0104110 <default_check+0x1c0>
c01040f7:	68 be bf 10 c0       	push   $0xc010bfbe
c01040fc:	68 36 be 10 c0       	push   $0xc010be36
c0104101:	68 21 01 00 00       	push   $0x121
c0104106:	68 4b be 10 c0       	push   $0xc010be4b
c010410b:	e8 76 cc ff ff       	call   c0100d86 <__panic>

    unsigned int nr_free_store = nr_free;
c0104110:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0104115:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104118:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c010411f:	00 00 00 
    //--------------------------------------

    free_pages(p0 + 2, 3);
c0104122:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104125:	83 c0 40             	add    $0x40,%eax
c0104128:	83 ec 08             	sub    $0x8,%esp
c010412b:	6a 03                	push   $0x3
c010412d:	50                   	push   %eax
c010412e:	e8 dc 0e 00 00       	call   c010500f <free_pages>
c0104133:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0104136:	83 ec 0c             	sub    $0xc,%esp
c0104139:	6a 04                	push   $0x4
c010413b:	e8 63 0e 00 00       	call   c0104fa3 <alloc_pages>
c0104140:	83 c4 10             	add    $0x10,%esp
c0104143:	85 c0                	test   %eax,%eax
c0104145:	74 19                	je     c0104160 <default_check+0x210>
c0104147:	68 64 c0 10 c0       	push   $0xc010c064
c010414c:	68 36 be 10 c0       	push   $0xc010be36
c0104151:	68 28 01 00 00       	push   $0x128
c0104156:	68 4b be 10 c0       	push   $0xc010be4b
c010415b:	e8 26 cc ff ff       	call   c0100d86 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104160:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104163:	83 c0 40             	add    $0x40,%eax
c0104166:	83 c0 04             	add    $0x4,%eax
c0104169:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104170:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104173:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104176:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104179:	0f a3 10             	bt     %edx,(%eax)
c010417c:	19 c0                	sbb    %eax,%eax
c010417e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104181:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104185:	0f 95 c0             	setne  %al
c0104188:	0f b6 c0             	movzbl %al,%eax
c010418b:	85 c0                	test   %eax,%eax
c010418d:	74 0e                	je     c010419d <default_check+0x24d>
c010418f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104192:	83 c0 40             	add    $0x40,%eax
c0104195:	8b 40 08             	mov    0x8(%eax),%eax
c0104198:	83 f8 03             	cmp    $0x3,%eax
c010419b:	74 19                	je     c01041b6 <default_check+0x266>
c010419d:	68 7c c0 10 c0       	push   $0xc010c07c
c01041a2:	68 36 be 10 c0       	push   $0xc010be36
c01041a7:	68 29 01 00 00       	push   $0x129
c01041ac:	68 4b be 10 c0       	push   $0xc010be4b
c01041b1:	e8 d0 cb ff ff       	call   c0100d86 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01041b6:	83 ec 0c             	sub    $0xc,%esp
c01041b9:	6a 03                	push   $0x3
c01041bb:	e8 e3 0d 00 00       	call   c0104fa3 <alloc_pages>
c01041c0:	83 c4 10             	add    $0x10,%esp
c01041c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01041c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01041ca:	75 19                	jne    c01041e5 <default_check+0x295>
c01041cc:	68 a8 c0 10 c0       	push   $0xc010c0a8
c01041d1:	68 36 be 10 c0       	push   $0xc010be36
c01041d6:	68 2a 01 00 00       	push   $0x12a
c01041db:	68 4b be 10 c0       	push   $0xc010be4b
c01041e0:	e8 a1 cb ff ff       	call   c0100d86 <__panic>
    assert(alloc_page() == NULL);
c01041e5:	83 ec 0c             	sub    $0xc,%esp
c01041e8:	6a 01                	push   $0x1
c01041ea:	e8 b4 0d 00 00       	call   c0104fa3 <alloc_pages>
c01041ef:	83 c4 10             	add    $0x10,%esp
c01041f2:	85 c0                	test   %eax,%eax
c01041f4:	74 19                	je     c010420f <default_check+0x2bf>
c01041f6:	68 be bf 10 c0       	push   $0xc010bfbe
c01041fb:	68 36 be 10 c0       	push   $0xc010be36
c0104200:	68 2b 01 00 00       	push   $0x12b
c0104205:	68 4b be 10 c0       	push   $0xc010be4b
c010420a:	e8 77 cb ff ff       	call   c0100d86 <__panic>
    assert(p0 + 2 == p1);
c010420f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104212:	83 c0 40             	add    $0x40,%eax
c0104215:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104218:	74 19                	je     c0104233 <default_check+0x2e3>
c010421a:	68 c6 c0 10 c0       	push   $0xc010c0c6
c010421f:	68 36 be 10 c0       	push   $0xc010be36
c0104224:	68 2c 01 00 00       	push   $0x12c
c0104229:	68 4b be 10 c0       	push   $0xc010be4b
c010422e:	e8 53 cb ff ff       	call   c0100d86 <__panic>

    p2 = p0 + 1;
c0104233:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104236:	83 c0 20             	add    $0x20,%eax
c0104239:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c010423c:	83 ec 08             	sub    $0x8,%esp
c010423f:	6a 01                	push   $0x1
c0104241:	ff 75 e8             	pushl  -0x18(%ebp)
c0104244:	e8 c6 0d 00 00       	call   c010500f <free_pages>
c0104249:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c010424c:	83 ec 08             	sub    $0x8,%esp
c010424f:	6a 03                	push   $0x3
c0104251:	ff 75 e0             	pushl  -0x20(%ebp)
c0104254:	e8 b6 0d 00 00       	call   c010500f <free_pages>
c0104259:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c010425c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010425f:	83 c0 04             	add    $0x4,%eax
c0104262:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104269:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010426c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010426f:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104272:	0f a3 10             	bt     %edx,(%eax)
c0104275:	19 c0                	sbb    %eax,%eax
c0104277:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010427a:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010427e:	0f 95 c0             	setne  %al
c0104281:	0f b6 c0             	movzbl %al,%eax
c0104284:	85 c0                	test   %eax,%eax
c0104286:	74 0b                	je     c0104293 <default_check+0x343>
c0104288:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010428b:	8b 40 08             	mov    0x8(%eax),%eax
c010428e:	83 f8 01             	cmp    $0x1,%eax
c0104291:	74 19                	je     c01042ac <default_check+0x35c>
c0104293:	68 d4 c0 10 c0       	push   $0xc010c0d4
c0104298:	68 36 be 10 c0       	push   $0xc010be36
c010429d:	68 31 01 00 00       	push   $0x131
c01042a2:	68 4b be 10 c0       	push   $0xc010be4b
c01042a7:	e8 da ca ff ff       	call   c0100d86 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01042ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042af:	83 c0 04             	add    $0x4,%eax
c01042b2:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01042b9:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042bc:	8b 45 90             	mov    -0x70(%ebp),%eax
c01042bf:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01042c2:	0f a3 10             	bt     %edx,(%eax)
c01042c5:	19 c0                	sbb    %eax,%eax
c01042c7:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01042ca:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01042ce:	0f 95 c0             	setne  %al
c01042d1:	0f b6 c0             	movzbl %al,%eax
c01042d4:	85 c0                	test   %eax,%eax
c01042d6:	74 0b                	je     c01042e3 <default_check+0x393>
c01042d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042db:	8b 40 08             	mov    0x8(%eax),%eax
c01042de:	83 f8 03             	cmp    $0x3,%eax
c01042e1:	74 19                	je     c01042fc <default_check+0x3ac>
c01042e3:	68 fc c0 10 c0       	push   $0xc010c0fc
c01042e8:	68 36 be 10 c0       	push   $0xc010be36
c01042ed:	68 32 01 00 00       	push   $0x132
c01042f2:	68 4b be 10 c0       	push   $0xc010be4b
c01042f7:	e8 8a ca ff ff       	call   c0100d86 <__panic>

    assert((p0 = alloc_page()) == p2 - 1); //!
c01042fc:	83 ec 0c             	sub    $0xc,%esp
c01042ff:	6a 01                	push   $0x1
c0104301:	e8 9d 0c 00 00       	call   c0104fa3 <alloc_pages>
c0104306:	83 c4 10             	add    $0x10,%esp
c0104309:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010430c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010430f:	83 e8 20             	sub    $0x20,%eax
c0104312:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104315:	74 19                	je     c0104330 <default_check+0x3e0>
c0104317:	68 22 c1 10 c0       	push   $0xc010c122
c010431c:	68 36 be 10 c0       	push   $0xc010be36
c0104321:	68 34 01 00 00       	push   $0x134
c0104326:	68 4b be 10 c0       	push   $0xc010be4b
c010432b:	e8 56 ca ff ff       	call   c0100d86 <__panic>
    free_page(p0);
c0104330:	83 ec 08             	sub    $0x8,%esp
c0104333:	6a 01                	push   $0x1
c0104335:	ff 75 e8             	pushl  -0x18(%ebp)
c0104338:	e8 d2 0c 00 00       	call   c010500f <free_pages>
c010433d:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104340:	83 ec 0c             	sub    $0xc,%esp
c0104343:	6a 02                	push   $0x2
c0104345:	e8 59 0c 00 00       	call   c0104fa3 <alloc_pages>
c010434a:	83 c4 10             	add    $0x10,%esp
c010434d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104350:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104353:	83 c0 20             	add    $0x20,%eax
c0104356:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104359:	74 19                	je     c0104374 <default_check+0x424>
c010435b:	68 40 c1 10 c0       	push   $0xc010c140
c0104360:	68 36 be 10 c0       	push   $0xc010be36
c0104365:	68 36 01 00 00       	push   $0x136
c010436a:	68 4b be 10 c0       	push   $0xc010be4b
c010436f:	e8 12 ca ff ff       	call   c0100d86 <__panic>

    free_pages(p0, 2);
c0104374:	83 ec 08             	sub    $0x8,%esp
c0104377:	6a 02                	push   $0x2
c0104379:	ff 75 e8             	pushl  -0x18(%ebp)
c010437c:	e8 8e 0c 00 00       	call   c010500f <free_pages>
c0104381:	83 c4 10             	add    $0x10,%esp
    //test();
    free_page(p2);
c0104384:	83 ec 08             	sub    $0x8,%esp
c0104387:	6a 01                	push   $0x1
c0104389:	ff 75 dc             	pushl  -0x24(%ebp)
c010438c:	e8 7e 0c 00 00       	call   c010500f <free_pages>
c0104391:	83 c4 10             	add    $0x10,%esp
    //test();

    assert((p0 = alloc_pages(5)) != NULL); //!
c0104394:	83 ec 0c             	sub    $0xc,%esp
c0104397:	6a 05                	push   $0x5
c0104399:	e8 05 0c 00 00       	call   c0104fa3 <alloc_pages>
c010439e:	83 c4 10             	add    $0x10,%esp
c01043a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043a4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01043a8:	75 19                	jne    c01043c3 <default_check+0x473>
c01043aa:	68 60 c1 10 c0       	push   $0xc010c160
c01043af:	68 36 be 10 c0       	push   $0xc010be36
c01043b4:	68 3d 01 00 00       	push   $0x13d
c01043b9:	68 4b be 10 c0       	push   $0xc010be4b
c01043be:	e8 c3 c9 ff ff       	call   c0100d86 <__panic>
    assert(alloc_page() == NULL);
c01043c3:	83 ec 0c             	sub    $0xc,%esp
c01043c6:	6a 01                	push   $0x1
c01043c8:	e8 d6 0b 00 00       	call   c0104fa3 <alloc_pages>
c01043cd:	83 c4 10             	add    $0x10,%esp
c01043d0:	85 c0                	test   %eax,%eax
c01043d2:	74 19                	je     c01043ed <default_check+0x49d>
c01043d4:	68 be bf 10 c0       	push   $0xc010bfbe
c01043d9:	68 36 be 10 c0       	push   $0xc010be36
c01043de:	68 3e 01 00 00       	push   $0x13e
c01043e3:	68 4b be 10 c0       	push   $0xc010be4b
c01043e8:	e8 99 c9 ff ff       	call   c0100d86 <__panic>

    assert(nr_free == 0);
c01043ed:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c01043f2:	85 c0                	test   %eax,%eax
c01043f4:	74 19                	je     c010440f <default_check+0x4bf>
c01043f6:	68 11 c0 10 c0       	push   $0xc010c011
c01043fb:	68 36 be 10 c0       	push   $0xc010be36
c0104400:	68 40 01 00 00       	push   $0x140
c0104405:	68 4b be 10 c0       	push   $0xc010be4b
c010440a:	e8 77 c9 ff ff       	call   c0100d86 <__panic>
    nr_free = nr_free_store;
c010440f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104412:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c

    free_list = free_list_store;
c0104417:	8b 45 80             	mov    -0x80(%ebp),%eax
c010441a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010441d:	a3 84 3f 1a c0       	mov    %eax,0xc01a3f84
c0104422:	89 15 88 3f 1a c0    	mov    %edx,0xc01a3f88
    free_pages(p0, 5);
c0104428:	83 ec 08             	sub    $0x8,%esp
c010442b:	6a 05                	push   $0x5
c010442d:	ff 75 e8             	pushl  -0x18(%ebp)
c0104430:	e8 da 0b 00 00       	call   c010500f <free_pages>
c0104435:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c0104438:	c7 45 ec 84 3f 1a c0 	movl   $0xc01a3f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c010443f:	eb 50                	jmp    c0104491 <default_check+0x541>
    {
        assert(le->next->prev == le && le->prev->next == le);
c0104441:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104444:	8b 40 04             	mov    0x4(%eax),%eax
c0104447:	8b 00                	mov    (%eax),%eax
c0104449:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010444c:	75 0d                	jne    c010445b <default_check+0x50b>
c010444e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104451:	8b 00                	mov    (%eax),%eax
c0104453:	8b 40 04             	mov    0x4(%eax),%eax
c0104456:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104459:	74 19                	je     c0104474 <default_check+0x524>
c010445b:	68 80 c1 10 c0       	push   $0xc010c180
c0104460:	68 36 be 10 c0       	push   $0xc010be36
c0104465:	68 49 01 00 00       	push   $0x149
c010446a:	68 4b be 10 c0       	push   $0xc010be4b
c010446f:	e8 12 c9 ff ff       	call   c0100d86 <__panic>
        struct Page *p = le2page(le, page_link);
c0104474:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104477:	83 e8 0c             	sub    $0xc,%eax
c010447a:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count--, total -= p->property;
c010447d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104481:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104484:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104487:	8b 48 08             	mov    0x8(%eax),%ecx
c010448a:	89 d0                	mov    %edx,%eax
c010448c:	29 c8                	sub    %ecx,%eax
c010448e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104491:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104494:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0104497:	8b 45 88             	mov    -0x78(%ebp),%eax
c010449a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c010449d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01044a0:	81 7d ec 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x14(%ebp)
c01044a7:	75 98                	jne    c0104441 <default_check+0x4f1>
    }
    assert(count == 0);
c01044a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044ad:	74 19                	je     c01044c8 <default_check+0x578>
c01044af:	68 ad c1 10 c0       	push   $0xc010c1ad
c01044b4:	68 36 be 10 c0       	push   $0xc010be36
c01044b9:	68 4d 01 00 00       	push   $0x14d
c01044be:	68 4b be 10 c0       	push   $0xc010be4b
c01044c3:	e8 be c8 ff ff       	call   c0100d86 <__panic>
    assert(total == 0);
c01044c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044cc:	74 19                	je     c01044e7 <default_check+0x597>
c01044ce:	68 b8 c1 10 c0       	push   $0xc010c1b8
c01044d3:	68 36 be 10 c0       	push   $0xc010be36
c01044d8:	68 4e 01 00 00       	push   $0x14e
c01044dd:	68 4b be 10 c0       	push   $0xc010be4b
c01044e2:	e8 9f c8 ff ff       	call   c0100d86 <__panic>
}
c01044e7:	90                   	nop
c01044e8:	c9                   	leave  
c01044e9:	c3                   	ret    

c01044ea <test>:
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

static void test(void)
{   //我自己写的
c01044ea:	55                   	push   %ebp
c01044eb:	89 e5                	mov    %esp,%ebp
c01044ed:	83 ec 18             	sub    $0x18,%esp
c01044f0:	c7 45 f0 84 3f 1a c0 	movl   $0xc01a3f84,-0x10(%ebp)
c01044f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044fa:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01044fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != &free_list)
c0104500:	eb 30                	jmp    c0104532 <test+0x48>
    {
        cprintf("%x %d  ", le2page(le, page_link), le2page(le, page_link)->property);
c0104502:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104505:	83 e8 0c             	sub    $0xc,%eax
c0104508:	8b 40 08             	mov    0x8(%eax),%eax
c010450b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010450e:	83 ea 0c             	sub    $0xc,%edx
c0104511:	83 ec 04             	sub    $0x4,%esp
c0104514:	50                   	push   %eax
c0104515:	52                   	push   %edx
c0104516:	68 f4 c1 10 c0       	push   $0xc010c1f4
c010451b:	e8 28 be ff ff       	call   c0100348 <cprintf>
c0104520:	83 c4 10             	add    $0x10,%esp
c0104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104526:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104529:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010452c:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010452f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != &free_list)
c0104532:	81 7d f4 84 3f 1a c0 	cmpl   $0xc01a3f84,-0xc(%ebp)
c0104539:	75 c7                	jne    c0104502 <test+0x18>
    }
    cprintf("\n");
c010453b:	83 ec 0c             	sub    $0xc,%esp
c010453e:	68 fc c1 10 c0       	push   $0xc010c1fc
c0104543:	e8 00 be ff ff       	call   c0100348 <cprintf>
c0104548:	83 c4 10             	add    $0x10,%esp
}
c010454b:	90                   	nop
c010454c:	c9                   	leave  
c010454d:	c3                   	ret    

c010454e <__intr_save>:
__intr_save(void) {
c010454e:	55                   	push   %ebp
c010454f:	89 e5                	mov    %esp,%ebp
c0104551:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104554:	9c                   	pushf  
c0104555:	58                   	pop    %eax
c0104556:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104559:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010455c:	25 00 02 00 00       	and    $0x200,%eax
c0104561:	85 c0                	test   %eax,%eax
c0104563:	74 0c                	je     c0104571 <__intr_save+0x23>
        intr_disable();
c0104565:	e8 21 da ff ff       	call   c0101f8b <intr_disable>
        return 1;
c010456a:	b8 01 00 00 00       	mov    $0x1,%eax
c010456f:	eb 05                	jmp    c0104576 <__intr_save+0x28>
    return 0;
c0104571:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104576:	c9                   	leave  
c0104577:	c3                   	ret    

c0104578 <__intr_restore>:
__intr_restore(bool flag) {
c0104578:	55                   	push   %ebp
c0104579:	89 e5                	mov    %esp,%ebp
c010457b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010457e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104582:	74 05                	je     c0104589 <__intr_restore+0x11>
        intr_enable();
c0104584:	e8 fa d9 ff ff       	call   c0101f83 <intr_enable>
}
c0104589:	90                   	nop
c010458a:	c9                   	leave  
c010458b:	c3                   	ret    

c010458c <page2ppn>:
page2ppn(struct Page *page) {
c010458c:	55                   	push   %ebp
c010458d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010458f:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0104595:	8b 45 08             	mov    0x8(%ebp),%eax
c0104598:	29 d0                	sub    %edx,%eax
c010459a:	c1 f8 05             	sar    $0x5,%eax
}
c010459d:	5d                   	pop    %ebp
c010459e:	c3                   	ret    

c010459f <page2pa>:
page2pa(struct Page *page) {
c010459f:	55                   	push   %ebp
c01045a0:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01045a2:	ff 75 08             	pushl  0x8(%ebp)
c01045a5:	e8 e2 ff ff ff       	call   c010458c <page2ppn>
c01045aa:	83 c4 04             	add    $0x4,%esp
c01045ad:	c1 e0 0c             	shl    $0xc,%eax
}
c01045b0:	c9                   	leave  
c01045b1:	c3                   	ret    

c01045b2 <pa2page>:
pa2page(uintptr_t pa) {
c01045b2:	55                   	push   %ebp
c01045b3:	89 e5                	mov    %esp,%ebp
c01045b5:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c01045b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01045bb:	c1 e8 0c             	shr    $0xc,%eax
c01045be:	89 c2                	mov    %eax,%edx
c01045c0:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01045c5:	39 c2                	cmp    %eax,%edx
c01045c7:	72 14                	jb     c01045dd <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c01045c9:	83 ec 04             	sub    $0x4,%esp
c01045cc:	68 00 c2 10 c0       	push   $0xc010c200
c01045d1:	6a 5e                	push   $0x5e
c01045d3:	68 1f c2 10 c0       	push   $0xc010c21f
c01045d8:	e8 a9 c7 ff ff       	call   c0100d86 <__panic>
    return &pages[PPN(pa)];
c01045dd:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c01045e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01045e6:	c1 e8 0c             	shr    $0xc,%eax
c01045e9:	c1 e0 05             	shl    $0x5,%eax
c01045ec:	01 d0                	add    %edx,%eax
}
c01045ee:	c9                   	leave  
c01045ef:	c3                   	ret    

c01045f0 <page2kva>:
page2kva(struct Page *page) {
c01045f0:	55                   	push   %ebp
c01045f1:	89 e5                	mov    %esp,%ebp
c01045f3:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c01045f6:	ff 75 08             	pushl  0x8(%ebp)
c01045f9:	e8 a1 ff ff ff       	call   c010459f <page2pa>
c01045fe:	83 c4 04             	add    $0x4,%esp
c0104601:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104604:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104607:	c1 e8 0c             	shr    $0xc,%eax
c010460a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010460d:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0104612:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104615:	72 14                	jb     c010462b <page2kva+0x3b>
c0104617:	ff 75 f4             	pushl  -0xc(%ebp)
c010461a:	68 30 c2 10 c0       	push   $0xc010c230
c010461f:	6a 65                	push   $0x65
c0104621:	68 1f c2 10 c0       	push   $0xc010c21f
c0104626:	e8 5b c7 ff ff       	call   c0100d86 <__panic>
c010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104633:	c9                   	leave  
c0104634:	c3                   	ret    

c0104635 <kva2page>:
kva2page(void *kva) {
c0104635:	55                   	push   %ebp
c0104636:	89 e5                	mov    %esp,%ebp
c0104638:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c010463b:	8b 45 08             	mov    0x8(%ebp),%eax
c010463e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104641:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104648:	77 14                	ja     c010465e <kva2page+0x29>
c010464a:	ff 75 f4             	pushl  -0xc(%ebp)
c010464d:	68 54 c2 10 c0       	push   $0xc010c254
c0104652:	6a 6a                	push   $0x6a
c0104654:	68 1f c2 10 c0       	push   $0xc010c21f
c0104659:	e8 28 c7 ff ff       	call   c0100d86 <__panic>
c010465e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104661:	05 00 00 00 40       	add    $0x40000000,%eax
c0104666:	83 ec 0c             	sub    $0xc,%esp
c0104669:	50                   	push   %eax
c010466a:	e8 43 ff ff ff       	call   c01045b2 <pa2page>
c010466f:	83 c4 10             	add    $0x10,%esp
}
c0104672:	c9                   	leave  
c0104673:	c3                   	ret    

c0104674 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104674:	55                   	push   %ebp
c0104675:	89 e5                	mov    %esp,%ebp
c0104677:	83 ec 18             	sub    $0x18,%esp
  struct Page * page = alloc_pages(1 << order);
c010467a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010467d:	ba 01 00 00 00       	mov    $0x1,%edx
c0104682:	89 c1                	mov    %eax,%ecx
c0104684:	d3 e2                	shl    %cl,%edx
c0104686:	89 d0                	mov    %edx,%eax
c0104688:	83 ec 0c             	sub    $0xc,%esp
c010468b:	50                   	push   %eax
c010468c:	e8 12 09 00 00       	call   c0104fa3 <alloc_pages>
c0104691:	83 c4 10             	add    $0x10,%esp
c0104694:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104697:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010469b:	75 07                	jne    c01046a4 <__slob_get_free_pages+0x30>
    return NULL;
c010469d:	b8 00 00 00 00       	mov    $0x0,%eax
c01046a2:	eb 0e                	jmp    c01046b2 <__slob_get_free_pages+0x3e>
  return page2kva(page);
c01046a4:	83 ec 0c             	sub    $0xc,%esp
c01046a7:	ff 75 f4             	pushl  -0xc(%ebp)
c01046aa:	e8 41 ff ff ff       	call   c01045f0 <page2kva>
c01046af:	83 c4 10             	add    $0x10,%esp
}
c01046b2:	c9                   	leave  
c01046b3:	c3                   	ret    

c01046b4 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c01046b4:	55                   	push   %ebp
c01046b5:	89 e5                	mov    %esp,%ebp
c01046b7:	53                   	push   %ebx
c01046b8:	83 ec 04             	sub    $0x4,%esp
  free_pages(kva2page(kva), 1 << order);
c01046bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046be:	ba 01 00 00 00       	mov    $0x1,%edx
c01046c3:	89 c1                	mov    %eax,%ecx
c01046c5:	d3 e2                	shl    %cl,%edx
c01046c7:	89 d0                	mov    %edx,%eax
c01046c9:	89 c3                	mov    %eax,%ebx
c01046cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ce:	83 ec 0c             	sub    $0xc,%esp
c01046d1:	50                   	push   %eax
c01046d2:	e8 5e ff ff ff       	call   c0104635 <kva2page>
c01046d7:	83 c4 10             	add    $0x10,%esp
c01046da:	83 ec 08             	sub    $0x8,%esp
c01046dd:	53                   	push   %ebx
c01046de:	50                   	push   %eax
c01046df:	e8 2b 09 00 00       	call   c010500f <free_pages>
c01046e4:	83 c4 10             	add    $0x10,%esp
}
c01046e7:	90                   	nop
c01046e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01046eb:	c9                   	leave  
c01046ec:	c3                   	ret    

c01046ed <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c01046ed:	55                   	push   %ebp
c01046ee:	89 e5                	mov    %esp,%ebp
c01046f0:	83 ec 28             	sub    $0x28,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c01046f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01046f6:	83 c0 08             	add    $0x8,%eax
c01046f9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01046fe:	76 16                	jbe    c0104716 <slob_alloc+0x29>
c0104700:	68 78 c2 10 c0       	push   $0xc010c278
c0104705:	68 97 c2 10 c0       	push   $0xc010c297
c010470a:	6a 64                	push   $0x64
c010470c:	68 ac c2 10 c0       	push   $0xc010c2ac
c0104711:	e8 70 c6 ff ff       	call   c0100d86 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104716:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c010471d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104724:	8b 45 08             	mov    0x8(%ebp),%eax
c0104727:	83 c0 07             	add    $0x7,%eax
c010472a:	c1 e8 03             	shr    $0x3,%eax
c010472d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104730:	e8 19 fe ff ff       	call   c010454e <__intr_save>
c0104735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104738:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c010473d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104740:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104743:	8b 40 04             	mov    0x4(%eax),%eax
c0104746:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104749:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010474d:	74 21                	je     c0104770 <slob_alloc+0x83>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010474f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104752:	8b 45 10             	mov    0x10(%ebp),%eax
c0104755:	01 d0                	add    %edx,%eax
c0104757:	8d 50 ff             	lea    -0x1(%eax),%edx
c010475a:	8b 45 10             	mov    0x10(%ebp),%eax
c010475d:	f7 d8                	neg    %eax
c010475f:	21 d0                	and    %edx,%eax
c0104761:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104764:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104767:	2b 45 f0             	sub    -0x10(%ebp),%eax
c010476a:	c1 f8 03             	sar    $0x3,%eax
c010476d:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104770:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104773:	8b 00                	mov    (%eax),%eax
c0104775:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104778:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010477b:	01 ca                	add    %ecx,%edx
c010477d:	39 d0                	cmp    %edx,%eax
c010477f:	0f 8c b1 00 00 00    	jl     c0104836 <slob_alloc+0x149>
			if (delta) { /* need to fragment head to align? */
c0104785:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104789:	74 38                	je     c01047c3 <slob_alloc+0xd6>
				aligned->units = cur->units - delta;
c010478b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010478e:	8b 00                	mov    (%eax),%eax
c0104790:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104793:	89 c2                	mov    %eax,%edx
c0104795:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104798:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c010479a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010479d:	8b 50 04             	mov    0x4(%eax),%edx
c01047a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047a3:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01047a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01047ac:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01047af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047b2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01047b5:	89 10                	mov    %edx,(%eax)
				prev = cur;
c01047b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c01047bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01047c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047c6:	8b 00                	mov    (%eax),%eax
c01047c8:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01047cb:	75 0e                	jne    c01047db <slob_alloc+0xee>
				prev->next = cur->next; /* unlink */
c01047cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047d0:	8b 50 04             	mov    0x4(%eax),%edx
c01047d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047d6:	89 50 04             	mov    %edx,0x4(%eax)
c01047d9:	eb 3c                	jmp    c0104817 <slob_alloc+0x12a>
			else { /* fragment */
				prev->next = cur + units;
c01047db:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047de:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01047e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047e8:	01 c2                	add    %eax,%edx
c01047ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047ed:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c01047f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047f3:	8b 10                	mov    (%eax),%edx
c01047f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047f8:	8b 40 04             	mov    0x4(%eax),%eax
c01047fb:	2b 55 e0             	sub    -0x20(%ebp),%edx
c01047fe:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104800:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104803:	8b 40 04             	mov    0x4(%eax),%eax
c0104806:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104809:	8b 52 04             	mov    0x4(%edx),%edx
c010480c:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c010480f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104812:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104815:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104817:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010481a:	a3 e8 f9 12 c0       	mov    %eax,0xc012f9e8
			spin_unlock_irqrestore(&slob_lock, flags);
c010481f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104822:	83 ec 0c             	sub    $0xc,%esp
c0104825:	50                   	push   %eax
c0104826:	e8 4d fd ff ff       	call   c0104578 <__intr_restore>
c010482b:	83 c4 10             	add    $0x10,%esp
			return cur;
c010482e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104831:	e9 80 00 00 00       	jmp    c01048b6 <slob_alloc+0x1c9>
		}
		if (cur == slobfree) {
c0104836:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c010483b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010483e:	75 62                	jne    c01048a2 <slob_alloc+0x1b5>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104840:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104843:	83 ec 0c             	sub    $0xc,%esp
c0104846:	50                   	push   %eax
c0104847:	e8 2c fd ff ff       	call   c0104578 <__intr_restore>
c010484c:	83 c4 10             	add    $0x10,%esp

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c010484f:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104856:	75 07                	jne    c010485f <slob_alloc+0x172>
				return 0;
c0104858:	b8 00 00 00 00       	mov    $0x0,%eax
c010485d:	eb 57                	jmp    c01048b6 <slob_alloc+0x1c9>

			cur = (slob_t *)__slob_get_free_page(gfp);
c010485f:	83 ec 08             	sub    $0x8,%esp
c0104862:	6a 00                	push   $0x0
c0104864:	ff 75 0c             	pushl  0xc(%ebp)
c0104867:	e8 08 fe ff ff       	call   c0104674 <__slob_get_free_pages>
c010486c:	83 c4 10             	add    $0x10,%esp
c010486f:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104872:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104876:	75 07                	jne    c010487f <slob_alloc+0x192>
				return 0;
c0104878:	b8 00 00 00 00       	mov    $0x0,%eax
c010487d:	eb 37                	jmp    c01048b6 <slob_alloc+0x1c9>

			slob_free(cur, PAGE_SIZE);
c010487f:	83 ec 08             	sub    $0x8,%esp
c0104882:	68 00 10 00 00       	push   $0x1000
c0104887:	ff 75 f0             	pushl  -0x10(%ebp)
c010488a:	e8 29 00 00 00       	call   c01048b8 <slob_free>
c010488f:	83 c4 10             	add    $0x10,%esp
			spin_lock_irqsave(&slob_lock, flags);
c0104892:	e8 b7 fc ff ff       	call   c010454e <__intr_save>
c0104897:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c010489a:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c010489f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01048a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048ab:	8b 40 04             	mov    0x4(%eax),%eax
c01048ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01048b1:	e9 93 fe ff ff       	jmp    c0104749 <slob_alloc+0x5c>
		}
	}
}
c01048b6:	c9                   	leave  
c01048b7:	c3                   	ret    

c01048b8 <slob_free>:

static void slob_free(void *block, int size)
{
c01048b8:	55                   	push   %ebp
c01048b9:	89 e5                	mov    %esp,%ebp
c01048bb:	83 ec 18             	sub    $0x18,%esp
	slob_t *cur, *b = (slob_t *)block;
c01048be:	8b 45 08             	mov    0x8(%ebp),%eax
c01048c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01048c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01048c8:	0f 84 05 01 00 00    	je     c01049d3 <slob_free+0x11b>
		return;

	if (size)
c01048ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01048d2:	74 10                	je     c01048e4 <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c01048d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048d7:	83 c0 07             	add    $0x7,%eax
c01048da:	c1 e8 03             	shr    $0x3,%eax
c01048dd:	89 c2                	mov    %eax,%edx
c01048df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048e2:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01048e4:	e8 65 fc ff ff       	call   c010454e <__intr_save>
c01048e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01048ec:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c01048f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048f4:	eb 27                	jmp    c010491d <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01048f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f9:	8b 40 04             	mov    0x4(%eax),%eax
c01048fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01048ff:	72 13                	jb     c0104914 <slob_free+0x5c>
c0104901:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104904:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104907:	77 27                	ja     c0104930 <slob_free+0x78>
c0104909:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010490c:	8b 40 04             	mov    0x4(%eax),%eax
c010490f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104912:	72 1c                	jb     c0104930 <slob_free+0x78>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104917:	8b 40 04             	mov    0x4(%eax),%eax
c010491a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010491d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104920:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104923:	76 d1                	jbe    c01048f6 <slob_free+0x3e>
c0104925:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104928:	8b 40 04             	mov    0x4(%eax),%eax
c010492b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010492e:	73 c6                	jae    c01048f6 <slob_free+0x3e>
			break;

	if (b + b->units == cur->next) {
c0104930:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104933:	8b 00                	mov    (%eax),%eax
c0104935:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010493c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010493f:	01 c2                	add    %eax,%edx
c0104941:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104944:	8b 40 04             	mov    0x4(%eax),%eax
c0104947:	39 c2                	cmp    %eax,%edx
c0104949:	75 25                	jne    c0104970 <slob_free+0xb8>
		b->units += cur->next->units;
c010494b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010494e:	8b 10                	mov    (%eax),%edx
c0104950:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104953:	8b 40 04             	mov    0x4(%eax),%eax
c0104956:	8b 00                	mov    (%eax),%eax
c0104958:	01 c2                	add    %eax,%edx
c010495a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010495d:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c010495f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104962:	8b 40 04             	mov    0x4(%eax),%eax
c0104965:	8b 50 04             	mov    0x4(%eax),%edx
c0104968:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010496b:	89 50 04             	mov    %edx,0x4(%eax)
c010496e:	eb 0c                	jmp    c010497c <slob_free+0xc4>
	} else
		b->next = cur->next;
c0104970:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104973:	8b 50 04             	mov    0x4(%eax),%edx
c0104976:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104979:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c010497c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010497f:	8b 00                	mov    (%eax),%eax
c0104981:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104988:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010498b:	01 d0                	add    %edx,%eax
c010498d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104990:	75 1f                	jne    c01049b1 <slob_free+0xf9>
		cur->units += b->units;
c0104992:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104995:	8b 10                	mov    (%eax),%edx
c0104997:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010499a:	8b 00                	mov    (%eax),%eax
c010499c:	01 c2                	add    %eax,%edx
c010499e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049a1:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c01049a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049a6:	8b 50 04             	mov    0x4(%eax),%edx
c01049a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ac:	89 50 04             	mov    %edx,0x4(%eax)
c01049af:	eb 09                	jmp    c01049ba <slob_free+0x102>
	} else
		cur->next = b;
c01049b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01049b7:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c01049ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049bd:	a3 e8 f9 12 c0       	mov    %eax,0xc012f9e8

	spin_unlock_irqrestore(&slob_lock, flags);
c01049c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049c5:	83 ec 0c             	sub    $0xc,%esp
c01049c8:	50                   	push   %eax
c01049c9:	e8 aa fb ff ff       	call   c0104578 <__intr_restore>
c01049ce:	83 c4 10             	add    $0x10,%esp
c01049d1:	eb 01                	jmp    c01049d4 <slob_free+0x11c>
		return;
c01049d3:	90                   	nop
}
c01049d4:	c9                   	leave  
c01049d5:	c3                   	ret    

c01049d6 <slob_init>:



void
slob_init(void) {
c01049d6:	55                   	push   %ebp
c01049d7:	89 e5                	mov    %esp,%ebp
c01049d9:	83 ec 08             	sub    $0x8,%esp
  cprintf("use SLOB allocator\n");
c01049dc:	83 ec 0c             	sub    $0xc,%esp
c01049df:	68 be c2 10 c0       	push   $0xc010c2be
c01049e4:	e8 5f b9 ff ff       	call   c0100348 <cprintf>
c01049e9:	83 c4 10             	add    $0x10,%esp
}
c01049ec:	90                   	nop
c01049ed:	c9                   	leave  
c01049ee:	c3                   	ret    

c01049ef <kmalloc_init>:

inline void 
kmalloc_init(void) {
c01049ef:	55                   	push   %ebp
c01049f0:	89 e5                	mov    %esp,%ebp
c01049f2:	83 ec 08             	sub    $0x8,%esp
    slob_init();
c01049f5:	e8 dc ff ff ff       	call   c01049d6 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c01049fa:	83 ec 0c             	sub    $0xc,%esp
c01049fd:	68 d2 c2 10 c0       	push   $0xc010c2d2
c0104a02:	e8 41 b9 ff ff       	call   c0100348 <cprintf>
c0104a07:	83 c4 10             	add    $0x10,%esp
}
c0104a0a:	90                   	nop
c0104a0b:	c9                   	leave  
c0104a0c:	c3                   	ret    

c0104a0d <slob_allocated>:

size_t
slob_allocated(void) {
c0104a0d:	55                   	push   %ebp
c0104a0e:	89 e5                	mov    %esp,%ebp
  return 0;
c0104a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104a15:	5d                   	pop    %ebp
c0104a16:	c3                   	ret    

c0104a17 <kallocated>:

size_t
kallocated(void) {
c0104a17:	55                   	push   %ebp
c0104a18:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104a1a:	e8 ee ff ff ff       	call   c0104a0d <slob_allocated>
}
c0104a1f:	5d                   	pop    %ebp
c0104a20:	c3                   	ret    

c0104a21 <find_order>:

static int find_order(int size)
{
c0104a21:	55                   	push   %ebp
c0104a22:	89 e5                	mov    %esp,%ebp
c0104a24:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104a27:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104a2e:	eb 07                	jmp    c0104a37 <find_order+0x16>
		order++;
c0104a30:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104a34:	d1 7d 08             	sarl   0x8(%ebp)
c0104a37:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104a3e:	7f f0                	jg     c0104a30 <find_order+0xf>
	return order;
c0104a40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104a43:	c9                   	leave  
c0104a44:	c3                   	ret    

c0104a45 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104a45:	55                   	push   %ebp
c0104a46:	89 e5                	mov    %esp,%ebp
c0104a48:	83 ec 18             	sub    $0x18,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104a4b:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104a52:	77 35                	ja     c0104a89 <__kmalloc+0x44>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a57:	83 c0 08             	add    $0x8,%eax
c0104a5a:	83 ec 04             	sub    $0x4,%esp
c0104a5d:	6a 00                	push   $0x0
c0104a5f:	ff 75 0c             	pushl  0xc(%ebp)
c0104a62:	50                   	push   %eax
c0104a63:	e8 85 fc ff ff       	call   c01046ed <slob_alloc>
c0104a68:	83 c4 10             	add    $0x10,%esp
c0104a6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104a6e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104a72:	74 0b                	je     c0104a7f <__kmalloc+0x3a>
c0104a74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a77:	83 c0 08             	add    $0x8,%eax
c0104a7a:	e9 af 00 00 00       	jmp    c0104b2e <__kmalloc+0xe9>
c0104a7f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a84:	e9 a5 00 00 00       	jmp    c0104b2e <__kmalloc+0xe9>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104a89:	83 ec 04             	sub    $0x4,%esp
c0104a8c:	6a 00                	push   $0x0
c0104a8e:	ff 75 0c             	pushl  0xc(%ebp)
c0104a91:	6a 0c                	push   $0xc
c0104a93:	e8 55 fc ff ff       	call   c01046ed <slob_alloc>
c0104a98:	83 c4 10             	add    $0x10,%esp
c0104a9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0104a9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104aa2:	75 0a                	jne    c0104aae <__kmalloc+0x69>
		return 0;
c0104aa4:	b8 00 00 00 00       	mov    $0x0,%eax
c0104aa9:	e9 80 00 00 00       	jmp    c0104b2e <__kmalloc+0xe9>

	bb->order = find_order(size);
c0104aae:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ab1:	83 ec 0c             	sub    $0xc,%esp
c0104ab4:	50                   	push   %eax
c0104ab5:	e8 67 ff ff ff       	call   c0104a21 <find_order>
c0104aba:	83 c4 10             	add    $0x10,%esp
c0104abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104ac0:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ac5:	8b 00                	mov    (%eax),%eax
c0104ac7:	83 ec 08             	sub    $0x8,%esp
c0104aca:	50                   	push   %eax
c0104acb:	ff 75 0c             	pushl  0xc(%ebp)
c0104ace:	e8 a1 fb ff ff       	call   c0104674 <__slob_get_free_pages>
c0104ad3:	83 c4 10             	add    $0x10,%esp
c0104ad6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104ad9:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104adf:	8b 40 04             	mov    0x4(%eax),%eax
c0104ae2:	85 c0                	test   %eax,%eax
c0104ae4:	74 33                	je     c0104b19 <__kmalloc+0xd4>
		spin_lock_irqsave(&block_lock, flags);
c0104ae6:	e8 63 fa ff ff       	call   c010454e <__intr_save>
c0104aeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0104aee:	8b 15 90 3f 1a c0    	mov    0xc01a3f90,%edx
c0104af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104af7:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104afd:	a3 90 3f 1a c0       	mov    %eax,0xc01a3f90
		spin_unlock_irqrestore(&block_lock, flags);
c0104b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b05:	83 ec 0c             	sub    $0xc,%esp
c0104b08:	50                   	push   %eax
c0104b09:	e8 6a fa ff ff       	call   c0104578 <__intr_restore>
c0104b0e:	83 c4 10             	add    $0x10,%esp
		return bb->pages;
c0104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b14:	8b 40 04             	mov    0x4(%eax),%eax
c0104b17:	eb 15                	jmp    c0104b2e <__kmalloc+0xe9>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104b19:	83 ec 08             	sub    $0x8,%esp
c0104b1c:	6a 0c                	push   $0xc
c0104b1e:	ff 75 f4             	pushl  -0xc(%ebp)
c0104b21:	e8 92 fd ff ff       	call   c01048b8 <slob_free>
c0104b26:	83 c4 10             	add    $0x10,%esp
	return 0;
c0104b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b2e:	c9                   	leave  
c0104b2f:	c3                   	ret    

c0104b30 <kmalloc>:

void *
kmalloc(size_t size)
{
c0104b30:	55                   	push   %ebp
c0104b31:	89 e5                	mov    %esp,%ebp
c0104b33:	83 ec 08             	sub    $0x8,%esp
  return __kmalloc(size, 0);
c0104b36:	83 ec 08             	sub    $0x8,%esp
c0104b39:	6a 00                	push   $0x0
c0104b3b:	ff 75 08             	pushl  0x8(%ebp)
c0104b3e:	e8 02 ff ff ff       	call   c0104a45 <__kmalloc>
c0104b43:	83 c4 10             	add    $0x10,%esp
}
c0104b46:	c9                   	leave  
c0104b47:	c3                   	ret    

c0104b48 <kfree>:


void kfree(void *block)
{
c0104b48:	55                   	push   %ebp
c0104b49:	89 e5                	mov    %esp,%ebp
c0104b4b:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104b4e:	c7 45 f0 90 3f 1a c0 	movl   $0xc01a3f90,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104b55:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104b59:	0f 84 ab 00 00 00    	je     c0104c0a <kfree+0xc2>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b62:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104b67:	85 c0                	test   %eax,%eax
c0104b69:	0f 85 85 00 00 00    	jne    c0104bf4 <kfree+0xac>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104b6f:	e8 da f9 ff ff       	call   c010454e <__intr_save>
c0104b74:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104b77:	a1 90 3f 1a c0       	mov    0xc01a3f90,%eax
c0104b7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b7f:	eb 5e                	jmp    c0104bdf <kfree+0x97>
			if (bb->pages == block) {
c0104b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b84:	8b 40 04             	mov    0x4(%eax),%eax
c0104b87:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104b8a:	75 41                	jne    c0104bcd <kfree+0x85>
				*last = bb->next;
c0104b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b8f:	8b 50 08             	mov    0x8(%eax),%edx
c0104b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b95:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104b97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b9a:	83 ec 0c             	sub    $0xc,%esp
c0104b9d:	50                   	push   %eax
c0104b9e:	e8 d5 f9 ff ff       	call   c0104578 <__intr_restore>
c0104ba3:	83 c4 10             	add    $0x10,%esp
				__slob_free_pages((unsigned long)block, bb->order);
c0104ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ba9:	8b 10                	mov    (%eax),%edx
c0104bab:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bae:	83 ec 08             	sub    $0x8,%esp
c0104bb1:	52                   	push   %edx
c0104bb2:	50                   	push   %eax
c0104bb3:	e8 fc fa ff ff       	call   c01046b4 <__slob_free_pages>
c0104bb8:	83 c4 10             	add    $0x10,%esp
				slob_free(bb, sizeof(bigblock_t));
c0104bbb:	83 ec 08             	sub    $0x8,%esp
c0104bbe:	6a 0c                	push   $0xc
c0104bc0:	ff 75 f4             	pushl  -0xc(%ebp)
c0104bc3:	e8 f0 fc ff ff       	call   c01048b8 <slob_free>
c0104bc8:	83 c4 10             	add    $0x10,%esp
				return;
c0104bcb:	eb 3e                	jmp    c0104c0b <kfree+0xc3>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd0:	83 c0 08             	add    $0x8,%eax
c0104bd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd9:	8b 40 08             	mov    0x8(%eax),%eax
c0104bdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104be3:	75 9c                	jne    c0104b81 <kfree+0x39>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104be8:	83 ec 0c             	sub    $0xc,%esp
c0104beb:	50                   	push   %eax
c0104bec:	e8 87 f9 ff ff       	call   c0104578 <__intr_restore>
c0104bf1:	83 c4 10             	add    $0x10,%esp
	}

	slob_free((slob_t *)block - 1, 0);
c0104bf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bf7:	83 e8 08             	sub    $0x8,%eax
c0104bfa:	83 ec 08             	sub    $0x8,%esp
c0104bfd:	6a 00                	push   $0x0
c0104bff:	50                   	push   %eax
c0104c00:	e8 b3 fc ff ff       	call   c01048b8 <slob_free>
c0104c05:	83 c4 10             	add    $0x10,%esp
	return;
c0104c08:	eb 01                	jmp    c0104c0b <kfree+0xc3>
		return;
c0104c0a:	90                   	nop
}
c0104c0b:	c9                   	leave  
c0104c0c:	c3                   	ret    

c0104c0d <ksize>:


unsigned int ksize(const void *block)
{
c0104c0d:	55                   	push   %ebp
c0104c0e:	89 e5                	mov    %esp,%ebp
c0104c10:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104c13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c17:	75 07                	jne    c0104c20 <ksize+0x13>
		return 0;
c0104c19:	b8 00 00 00 00       	mov    $0x0,%eax
c0104c1e:	eb 73                	jmp    c0104c93 <ksize+0x86>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104c20:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c23:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c28:	85 c0                	test   %eax,%eax
c0104c2a:	75 5c                	jne    c0104c88 <ksize+0x7b>
		spin_lock_irqsave(&block_lock, flags);
c0104c2c:	e8 1d f9 ff ff       	call   c010454e <__intr_save>
c0104c31:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104c34:	a1 90 3f 1a c0       	mov    0xc01a3f90,%eax
c0104c39:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c3c:	eb 35                	jmp    c0104c73 <ksize+0x66>
			if (bb->pages == block) {
c0104c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c41:	8b 40 04             	mov    0x4(%eax),%eax
c0104c44:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104c47:	75 21                	jne    c0104c6a <ksize+0x5d>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c4c:	83 ec 0c             	sub    $0xc,%esp
c0104c4f:	50                   	push   %eax
c0104c50:	e8 23 f9 ff ff       	call   c0104578 <__intr_restore>
c0104c55:	83 c4 10             	add    $0x10,%esp
				return PAGE_SIZE << bb->order;
c0104c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c5b:	8b 00                	mov    (%eax),%eax
c0104c5d:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104c62:	89 c1                	mov    %eax,%ecx
c0104c64:	d3 e2                	shl    %cl,%edx
c0104c66:	89 d0                	mov    %edx,%eax
c0104c68:	eb 29                	jmp    c0104c93 <ksize+0x86>
		for (bb = bigblocks; bb; bb = bb->next)
c0104c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c6d:	8b 40 08             	mov    0x8(%eax),%eax
c0104c70:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c77:	75 c5                	jne    c0104c3e <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c7c:	83 ec 0c             	sub    $0xc,%esp
c0104c7f:	50                   	push   %eax
c0104c80:	e8 f3 f8 ff ff       	call   c0104578 <__intr_restore>
c0104c85:	83 c4 10             	add    $0x10,%esp
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c8b:	83 e8 08             	sub    $0x8,%eax
c0104c8e:	8b 00                	mov    (%eax),%eax
c0104c90:	c1 e0 03             	shl    $0x3,%eax
}
c0104c93:	c9                   	leave  
c0104c94:	c3                   	ret    

c0104c95 <page2ppn>:
page2ppn(struct Page *page) {
c0104c95:	55                   	push   %ebp
c0104c96:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104c98:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0104c9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ca1:	29 d0                	sub    %edx,%eax
c0104ca3:	c1 f8 05             	sar    $0x5,%eax
}
c0104ca6:	5d                   	pop    %ebp
c0104ca7:	c3                   	ret    

c0104ca8 <page2pa>:
page2pa(struct Page *page) {
c0104ca8:	55                   	push   %ebp
c0104ca9:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0104cab:	ff 75 08             	pushl  0x8(%ebp)
c0104cae:	e8 e2 ff ff ff       	call   c0104c95 <page2ppn>
c0104cb3:	83 c4 04             	add    $0x4,%esp
c0104cb6:	c1 e0 0c             	shl    $0xc,%eax
}
c0104cb9:	c9                   	leave  
c0104cba:	c3                   	ret    

c0104cbb <pa2page>:
pa2page(uintptr_t pa) {
c0104cbb:	55                   	push   %ebp
c0104cbc:	89 e5                	mov    %esp,%ebp
c0104cbe:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104cc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cc4:	c1 e8 0c             	shr    $0xc,%eax
c0104cc7:	89 c2                	mov    %eax,%edx
c0104cc9:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0104cce:	39 c2                	cmp    %eax,%edx
c0104cd0:	72 14                	jb     c0104ce6 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0104cd2:	83 ec 04             	sub    $0x4,%esp
c0104cd5:	68 f0 c2 10 c0       	push   $0xc010c2f0
c0104cda:	6a 5e                	push   $0x5e
c0104cdc:	68 0f c3 10 c0       	push   $0xc010c30f
c0104ce1:	e8 a0 c0 ff ff       	call   c0100d86 <__panic>
    return &pages[PPN(pa)];
c0104ce6:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0104cec:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cef:	c1 e8 0c             	shr    $0xc,%eax
c0104cf2:	c1 e0 05             	shl    $0x5,%eax
c0104cf5:	01 d0                	add    %edx,%eax
}
c0104cf7:	c9                   	leave  
c0104cf8:	c3                   	ret    

c0104cf9 <page2kva>:
page2kva(struct Page *page) {
c0104cf9:	55                   	push   %ebp
c0104cfa:	89 e5                	mov    %esp,%ebp
c0104cfc:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0104cff:	ff 75 08             	pushl  0x8(%ebp)
c0104d02:	e8 a1 ff ff ff       	call   c0104ca8 <page2pa>
c0104d07:	83 c4 04             	add    $0x4,%esp
c0104d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d10:	c1 e8 0c             	shr    $0xc,%eax
c0104d13:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d16:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0104d1b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104d1e:	72 14                	jb     c0104d34 <page2kva+0x3b>
c0104d20:	ff 75 f4             	pushl  -0xc(%ebp)
c0104d23:	68 20 c3 10 c0       	push   $0xc010c320
c0104d28:	6a 65                	push   $0x65
c0104d2a:	68 0f c3 10 c0       	push   $0xc010c30f
c0104d2f:	e8 52 c0 ff ff       	call   c0100d86 <__panic>
c0104d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d37:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104d3c:	c9                   	leave  
c0104d3d:	c3                   	ret    

c0104d3e <pte2page>:
pte2page(pte_t pte) {
c0104d3e:	55                   	push   %ebp
c0104d3f:	89 e5                	mov    %esp,%ebp
c0104d41:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0104d44:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d47:	83 e0 01             	and    $0x1,%eax
c0104d4a:	85 c0                	test   %eax,%eax
c0104d4c:	75 14                	jne    c0104d62 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0104d4e:	83 ec 04             	sub    $0x4,%esp
c0104d51:	68 44 c3 10 c0       	push   $0xc010c344
c0104d56:	6a 70                	push   $0x70
c0104d58:	68 0f c3 10 c0       	push   $0xc010c30f
c0104d5d:	e8 24 c0 ff ff       	call   c0100d86 <__panic>
    return pa2page(PTE_ADDR(pte));
c0104d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104d6a:	83 ec 0c             	sub    $0xc,%esp
c0104d6d:	50                   	push   %eax
c0104d6e:	e8 48 ff ff ff       	call   c0104cbb <pa2page>
c0104d73:	83 c4 10             	add    $0x10,%esp
}
c0104d76:	c9                   	leave  
c0104d77:	c3                   	ret    

c0104d78 <pde2page>:
pde2page(pde_t pde) {
c0104d78:	55                   	push   %ebp
c0104d79:	89 e5                	mov    %esp,%ebp
c0104d7b:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0104d7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104d86:	83 ec 0c             	sub    $0xc,%esp
c0104d89:	50                   	push   %eax
c0104d8a:	e8 2c ff ff ff       	call   c0104cbb <pa2page>
c0104d8f:	83 c4 10             	add    $0x10,%esp
}
c0104d92:	c9                   	leave  
c0104d93:	c3                   	ret    

c0104d94 <page_ref>:
page_ref(struct Page *page) {
c0104d94:	55                   	push   %ebp
c0104d95:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104d97:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d9a:	8b 00                	mov    (%eax),%eax
}
c0104d9c:	5d                   	pop    %ebp
c0104d9d:	c3                   	ret    

c0104d9e <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104d9e:	55                   	push   %ebp
c0104d9f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104da1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104da4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104da7:	89 10                	mov    %edx,(%eax)
}
c0104da9:	90                   	nop
c0104daa:	5d                   	pop    %ebp
c0104dab:	c3                   	ret    

c0104dac <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104dac:	55                   	push   %ebp
c0104dad:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0104db2:	8b 00                	mov    (%eax),%eax
c0104db4:	8d 50 01             	lea    0x1(%eax),%edx
c0104db7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dba:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104dbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dbf:	8b 00                	mov    (%eax),%eax
}
c0104dc1:	5d                   	pop    %ebp
c0104dc2:	c3                   	ret    

c0104dc3 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104dc3:	55                   	push   %ebp
c0104dc4:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104dc6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dc9:	8b 00                	mov    (%eax),%eax
c0104dcb:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104dce:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dd1:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104dd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dd6:	8b 00                	mov    (%eax),%eax
}
c0104dd8:	5d                   	pop    %ebp
c0104dd9:	c3                   	ret    

c0104dda <__intr_save>:
__intr_save(void) {
c0104dda:	55                   	push   %ebp
c0104ddb:	89 e5                	mov    %esp,%ebp
c0104ddd:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104de0:	9c                   	pushf  
c0104de1:	58                   	pop    %eax
c0104de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104de8:	25 00 02 00 00       	and    $0x200,%eax
c0104ded:	85 c0                	test   %eax,%eax
c0104def:	74 0c                	je     c0104dfd <__intr_save+0x23>
        intr_disable();
c0104df1:	e8 95 d1 ff ff       	call   c0101f8b <intr_disable>
        return 1;
c0104df6:	b8 01 00 00 00       	mov    $0x1,%eax
c0104dfb:	eb 05                	jmp    c0104e02 <__intr_save+0x28>
    return 0;
c0104dfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e02:	c9                   	leave  
c0104e03:	c3                   	ret    

c0104e04 <__intr_restore>:
__intr_restore(bool flag) {
c0104e04:	55                   	push   %ebp
c0104e05:	89 e5                	mov    %esp,%ebp
c0104e07:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104e0a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104e0e:	74 05                	je     c0104e15 <__intr_restore+0x11>
        intr_enable();
c0104e10:	e8 6e d1 ff ff       	call   c0101f83 <intr_enable>
}
c0104e15:	90                   	nop
c0104e16:	c9                   	leave  
c0104e17:	c3                   	ret    

c0104e18 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104e18:	55                   	push   %ebp
c0104e19:	89 e5                	mov    %esp,%ebp
    asm volatile("lgdt (%0)" ::"r"(pd));
c0104e1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e1e:	0f 01 10             	lgdtl  (%eax)
    asm volatile("movw %%ax, %%gs" ::"a"(USER_DS));
c0104e21:	b8 23 00 00 00       	mov    $0x23,%eax
c0104e26:	8e e8                	mov    %eax,%gs
    asm volatile("movw %%ax, %%fs" ::"a"(USER_DS));
c0104e28:	b8 23 00 00 00       	mov    $0x23,%eax
c0104e2d:	8e e0                	mov    %eax,%fs
    asm volatile("movw %%ax, %%es" ::"a"(KERNEL_DS));
c0104e2f:	b8 10 00 00 00       	mov    $0x10,%eax
c0104e34:	8e c0                	mov    %eax,%es
    asm volatile("movw %%ax, %%ds" ::"a"(KERNEL_DS));
c0104e36:	b8 10 00 00 00       	mov    $0x10,%eax
c0104e3b:	8e d8                	mov    %eax,%ds
    asm volatile("movw %%ax, %%ss" ::"a"(KERNEL_DS));
c0104e3d:	b8 10 00 00 00       	mov    $0x10,%eax
c0104e42:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile("ljmp %0, $1f\n 1:\n" ::"i"(KERNEL_CS));
c0104e44:	ea 4b 4e 10 c0 08 00 	ljmp   $0x8,$0xc0104e4b
}
c0104e4b:	90                   	nop
c0104e4c:	5d                   	pop    %ebp
c0104e4d:	c3                   	ret    

c0104e4e <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104e4e:	55                   	push   %ebp
c0104e4f:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104e51:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e54:	a3 c4 3f 1a c0       	mov    %eax,0xc01a3fc4
}
c0104e59:	90                   	nop
c0104e5a:	5d                   	pop    %ebp
c0104e5b:	c3                   	ret    

c0104e5c <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104e5c:	55                   	push   %ebp
c0104e5d:	89 e5                	mov    %esp,%ebp
c0104e5f:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104e62:	b8 00 f0 12 c0       	mov    $0xc012f000,%eax
c0104e67:	50                   	push   %eax
c0104e68:	e8 e1 ff ff ff       	call   c0104e4e <load_esp0>
c0104e6d:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c0104e70:	66 c7 05 c8 3f 1a c0 	movw   $0x10,0xc01a3fc8
c0104e77:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104e79:	66 c7 05 48 fa 12 c0 	movw   $0x68,0xc012fa48
c0104e80:	68 00 
c0104e82:	b8 c0 3f 1a c0       	mov    $0xc01a3fc0,%eax
c0104e87:	66 a3 4a fa 12 c0    	mov    %ax,0xc012fa4a
c0104e8d:	b8 c0 3f 1a c0       	mov    $0xc01a3fc0,%eax
c0104e92:	c1 e8 10             	shr    $0x10,%eax
c0104e95:	a2 4c fa 12 c0       	mov    %al,0xc012fa4c
c0104e9a:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c0104ea1:	83 e0 f0             	and    $0xfffffff0,%eax
c0104ea4:	83 c8 09             	or     $0x9,%eax
c0104ea7:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c0104eac:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c0104eb3:	83 e0 ef             	and    $0xffffffef,%eax
c0104eb6:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c0104ebb:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c0104ec2:	83 e0 9f             	and    $0xffffff9f,%eax
c0104ec5:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c0104eca:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c0104ed1:	83 c8 80             	or     $0xffffff80,%eax
c0104ed4:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c0104ed9:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c0104ee0:	83 e0 f0             	and    $0xfffffff0,%eax
c0104ee3:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c0104ee8:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c0104eef:	83 e0 ef             	and    $0xffffffef,%eax
c0104ef2:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c0104ef7:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c0104efe:	83 e0 df             	and    $0xffffffdf,%eax
c0104f01:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c0104f06:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c0104f0d:	83 c8 40             	or     $0x40,%eax
c0104f10:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c0104f15:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c0104f1c:	83 e0 7f             	and    $0x7f,%eax
c0104f1f:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c0104f24:	b8 c0 3f 1a c0       	mov    $0xc01a3fc0,%eax
c0104f29:	c1 e8 18             	shr    $0x18,%eax
c0104f2c:	a2 4f fa 12 c0       	mov    %al,0xc012fa4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104f31:	68 50 fa 12 c0       	push   $0xc012fa50
c0104f36:	e8 dd fe ff ff       	call   c0104e18 <lgdt>
c0104f3b:	83 c4 04             	add    $0x4,%esp
c0104f3e:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104f44:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104f48:	0f 00 d8             	ltr    %ax
}
c0104f4b:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0104f4c:	90                   	nop
c0104f4d:	c9                   	leave  
c0104f4e:	c3                   	ret    

c0104f4f <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104f4f:	55                   	push   %ebp
c0104f50:	89 e5                	mov    %esp,%ebp
c0104f52:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0104f55:	c7 05 ac 3f 1a c0 d8 	movl   $0xc010c1d8,0xc01a3fac
c0104f5c:	c1 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104f5f:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0104f64:	8b 00                	mov    (%eax),%eax
c0104f66:	83 ec 08             	sub    $0x8,%esp
c0104f69:	50                   	push   %eax
c0104f6a:	68 70 c3 10 c0       	push   $0xc010c370
c0104f6f:	e8 d4 b3 ff ff       	call   c0100348 <cprintf>
c0104f74:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c0104f77:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0104f7c:	8b 40 04             	mov    0x4(%eax),%eax
c0104f7f:	ff d0                	call   *%eax
}
c0104f81:	90                   	nop
c0104f82:	c9                   	leave  
c0104f83:	c3                   	ret    

c0104f84 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
c0104f84:	55                   	push   %ebp
c0104f85:	89 e5                	mov    %esp,%ebp
c0104f87:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c0104f8a:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0104f8f:	8b 40 08             	mov    0x8(%eax),%eax
c0104f92:	83 ec 08             	sub    $0x8,%esp
c0104f95:	ff 75 0c             	pushl  0xc(%ebp)
c0104f98:	ff 75 08             	pushl  0x8(%ebp)
c0104f9b:	ff d0                	call   *%eax
c0104f9d:	83 c4 10             	add    $0x10,%esp
}
c0104fa0:	90                   	nop
c0104fa1:	c9                   	leave  
c0104fa2:	c3                   	ret    

c0104fa3 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *
alloc_pages(size_t n) {
c0104fa3:	55                   	push   %ebp
c0104fa4:	89 e5                	mov    %esp,%ebp
c0104fa6:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = NULL;
c0104fa9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
c0104fb0:	e8 25 fe ff ff       	call   c0104dda <__intr_save>
c0104fb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
        {
            page = pmm_manager->alloc_pages(n);
c0104fb8:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0104fbd:	8b 40 0c             	mov    0xc(%eax),%eax
c0104fc0:	83 ec 0c             	sub    $0xc,%esp
c0104fc3:	ff 75 08             	pushl  0x8(%ebp)
c0104fc6:	ff d0                	call   *%eax
c0104fc8:	83 c4 10             	add    $0x10,%esp
c0104fcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        local_intr_restore(intr_flag);
c0104fce:	83 ec 0c             	sub    $0xc,%esp
c0104fd1:	ff 75 f0             	pushl  -0x10(%ebp)
c0104fd4:	e8 2b fe ff ff       	call   c0104e04 <__intr_restore>
c0104fd9:	83 c4 10             	add    $0x10,%esp

        if (page != NULL || n > 1 || swap_init_ok == 0)
c0104fdc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104fe0:	75 28                	jne    c010500a <alloc_pages+0x67>
c0104fe2:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0104fe6:	77 22                	ja     c010500a <alloc_pages+0x67>
c0104fe8:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c0104fed:	85 c0                	test   %eax,%eax
c0104fef:	74 19                	je     c010500a <alloc_pages+0x67>
            break;

        extern struct mm_struct *check_mm_struct;
        //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
c0104ff1:	8b 55 08             	mov    0x8(%ebp),%edx
c0104ff4:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0104ff9:	83 ec 04             	sub    $0x4,%esp
c0104ffc:	6a 00                	push   $0x0
c0104ffe:	52                   	push   %edx
c0104fff:	50                   	push   %eax
c0105000:	e8 b9 19 00 00       	call   c01069be <swap_out>
c0105005:	83 c4 10             	add    $0x10,%esp
    while (1) {
c0105008:	eb a6                	jmp    c0104fb0 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c010500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010500d:	c9                   	leave  
c010500e:	c3                   	ret    

c010500f <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void
free_pages(struct Page *base, size_t n) {
c010500f:	55                   	push   %ebp
c0105010:	89 e5                	mov    %esp,%ebp
c0105012:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0105015:	e8 c0 fd ff ff       	call   c0104dda <__intr_save>
c010501a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c010501d:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0105022:	8b 40 10             	mov    0x10(%eax),%eax
c0105025:	83 ec 08             	sub    $0x8,%esp
c0105028:	ff 75 0c             	pushl  0xc(%ebp)
c010502b:	ff 75 08             	pushl  0x8(%ebp)
c010502e:	ff d0                	call   *%eax
c0105030:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0105033:	83 ec 0c             	sub    $0xc,%esp
c0105036:	ff 75 f4             	pushl  -0xc(%ebp)
c0105039:	e8 c6 fd ff ff       	call   c0104e04 <__intr_restore>
c010503e:	83 c4 10             	add    $0x10,%esp
}
c0105041:	90                   	nop
c0105042:	c9                   	leave  
c0105043:	c3                   	ret    

c0105044 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
size_t
nr_free_pages(void) {
c0105044:	55                   	push   %ebp
c0105045:	89 e5                	mov    %esp,%ebp
c0105047:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010504a:	e8 8b fd ff ff       	call   c0104dda <__intr_save>
c010504f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0105052:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0105057:	8b 40 14             	mov    0x14(%eax),%eax
c010505a:	ff d0                	call   *%eax
c010505c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010505f:	83 ec 0c             	sub    $0xc,%esp
c0105062:	ff 75 f4             	pushl  -0xc(%ebp)
c0105065:	e8 9a fd ff ff       	call   c0104e04 <__intr_restore>
c010506a:	83 c4 10             	add    $0x10,%esp
    return ret;
c010506d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0105070:	c9                   	leave  
c0105071:	c3                   	ret    

c0105072 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0105072:	55                   	push   %ebp
c0105073:	89 e5                	mov    %esp,%ebp
c0105075:	57                   	push   %edi
c0105076:	56                   	push   %esi
c0105077:	53                   	push   %ebx
c0105078:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010507b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0105082:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105089:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0105090:	83 ec 0c             	sub    $0xc,%esp
c0105093:	68 87 c3 10 c0       	push   $0xc010c387
c0105098:	e8 ab b2 ff ff       	call   c0100348 <cprintf>
c010509d:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i++) {
c01050a0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01050a7:	e9 f4 00 00 00       	jmp    c01051a0 <page_init+0x12e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01050ac:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01050af:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050b2:	89 d0                	mov    %edx,%eax
c01050b4:	c1 e0 02             	shl    $0x2,%eax
c01050b7:	01 d0                	add    %edx,%eax
c01050b9:	c1 e0 02             	shl    $0x2,%eax
c01050bc:	01 c8                	add    %ecx,%eax
c01050be:	8b 50 08             	mov    0x8(%eax),%edx
c01050c1:	8b 40 04             	mov    0x4(%eax),%eax
c01050c4:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01050c7:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01050ca:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01050cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050d0:	89 d0                	mov    %edx,%eax
c01050d2:	c1 e0 02             	shl    $0x2,%eax
c01050d5:	01 d0                	add    %edx,%eax
c01050d7:	c1 e0 02             	shl    $0x2,%eax
c01050da:	01 c8                	add    %ecx,%eax
c01050dc:	8b 48 0c             	mov    0xc(%eax),%ecx
c01050df:	8b 58 10             	mov    0x10(%eax),%ebx
c01050e2:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01050e5:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01050e8:	01 c8                	add    %ecx,%eax
c01050ea:	11 da                	adc    %ebx,%edx
c01050ec:	89 45 98             	mov    %eax,-0x68(%ebp)
c01050ef:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01050f2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01050f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01050f8:	89 d0                	mov    %edx,%eax
c01050fa:	c1 e0 02             	shl    $0x2,%eax
c01050fd:	01 d0                	add    %edx,%eax
c01050ff:	c1 e0 02             	shl    $0x2,%eax
c0105102:	01 c8                	add    %ecx,%eax
c0105104:	83 c0 14             	add    $0x14,%eax
c0105107:	8b 00                	mov    (%eax),%eax
c0105109:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010510c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010510f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105112:	83 c0 ff             	add    $0xffffffff,%eax
c0105115:	83 d2 ff             	adc    $0xffffffff,%edx
c0105118:	89 c1                	mov    %eax,%ecx
c010511a:	89 d3                	mov    %edx,%ebx
c010511c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010511f:	89 55 80             	mov    %edx,-0x80(%ebp)
c0105122:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105125:	89 d0                	mov    %edx,%eax
c0105127:	c1 e0 02             	shl    $0x2,%eax
c010512a:	01 d0                	add    %edx,%eax
c010512c:	c1 e0 02             	shl    $0x2,%eax
c010512f:	03 45 80             	add    -0x80(%ebp),%eax
c0105132:	8b 50 10             	mov    0x10(%eax),%edx
c0105135:	8b 40 0c             	mov    0xc(%eax),%eax
c0105138:	ff 75 84             	pushl  -0x7c(%ebp)
c010513b:	53                   	push   %ebx
c010513c:	51                   	push   %ecx
c010513d:	ff 75 a4             	pushl  -0x5c(%ebp)
c0105140:	ff 75 a0             	pushl  -0x60(%ebp)
c0105143:	52                   	push   %edx
c0105144:	50                   	push   %eax
c0105145:	68 94 c3 10 c0       	push   $0xc010c394
c010514a:	e8 f9 b1 ff ff       	call   c0100348 <cprintf>
c010514f:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0105152:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105155:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105158:	89 d0                	mov    %edx,%eax
c010515a:	c1 e0 02             	shl    $0x2,%eax
c010515d:	01 d0                	add    %edx,%eax
c010515f:	c1 e0 02             	shl    $0x2,%eax
c0105162:	01 c8                	add    %ecx,%eax
c0105164:	83 c0 14             	add    $0x14,%eax
c0105167:	8b 00                	mov    (%eax),%eax
c0105169:	83 f8 01             	cmp    $0x1,%eax
c010516c:	75 2e                	jne    c010519c <page_init+0x12a>
            if (maxpa < end && begin < KMEMSIZE) {
c010516e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105171:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105174:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0105177:	89 d0                	mov    %edx,%eax
c0105179:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c010517c:	73 1e                	jae    c010519c <page_init+0x12a>
c010517e:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0105183:	b8 00 00 00 00       	mov    $0x0,%eax
c0105188:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c010518b:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c010518e:	72 0c                	jb     c010519c <page_init+0x12a>
                maxpa = end;
c0105190:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105193:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105196:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105199:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i++) {
c010519c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01051a0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01051a3:	8b 00                	mov    (%eax),%eax
c01051a5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01051a8:	0f 8c fe fe ff ff    	jl     c01050ac <page_init+0x3a>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01051ae:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01051b3:	b8 00 00 00 00       	mov    $0x0,%eax
c01051b8:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c01051bb:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c01051be:	73 0e                	jae    c01051ce <page_init+0x15c>
        maxpa = KMEMSIZE;
c01051c0:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01051c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    // generated by ld file
    extern char end[];

    npage = maxpa / PGSIZE;
c01051ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01051d4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01051d8:	c1 ea 0c             	shr    $0xc,%edx
c01051db:	a3 a4 3f 1a c0       	mov    %eax,0xc01a3fa4
    // the start of these pages
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01051e0:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c01051e7:	b8 54 61 1a c0       	mov    $0xc01a6154,%eax
c01051ec:	8d 50 ff             	lea    -0x1(%eax),%edx
c01051ef:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01051f2:	01 d0                	add    %edx,%eax
c01051f4:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01051f7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01051fa:	ba 00 00 00 00       	mov    $0x0,%edx
c01051ff:	f7 75 c0             	divl   -0x40(%ebp)
c0105202:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105205:	29 d0                	sub    %edx,%eax
c0105207:	a3 a0 3f 1a c0       	mov    %eax,0xc01a3fa0

    for (i = 0; i < npage; i++) {
c010520c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105213:	eb 29                	jmp    c010523e <page_init+0x1cc>
        SetPageReserved(pages + i);
c0105215:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c010521b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010521e:	c1 e0 05             	shl    $0x5,%eax
c0105221:	01 d0                	add    %edx,%eax
c0105223:	83 c0 04             	add    $0x4,%eax
c0105226:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c010522d:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105230:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105233:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105236:	0f ab 10             	bts    %edx,(%eax)
}
c0105239:	90                   	nop
    for (i = 0; i < npage; i++) {
c010523a:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010523e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105241:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0105246:	39 c2                	cmp    %eax,%edx
c0105248:	72 cb                	jb     c0105215 <page_init+0x1a3>
    }

    //the start of free memory
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010524a:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c010524f:	c1 e0 05             	shl    $0x5,%eax
c0105252:	89 c2                	mov    %eax,%edx
c0105254:	a1 a0 3f 1a c0       	mov    0xc01a3fa0,%eax
c0105259:	01 d0                	add    %edx,%eax
c010525b:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010525e:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0105265:	77 17                	ja     c010527e <page_init+0x20c>
c0105267:	ff 75 b8             	pushl  -0x48(%ebp)
c010526a:	68 c4 c3 10 c0       	push   $0xc010c3c4
c010526f:	68 ee 00 00 00       	push   $0xee
c0105274:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105279:	e8 08 bb ff ff       	call   c0100d86 <__panic>
c010527e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105281:	05 00 00 00 40       	add    $0x40000000,%eax
c0105286:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i++) {
c0105289:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105290:	e9 53 01 00 00       	jmp    c01053e8 <page_init+0x376>
        // memmap is the already existing memory layout given by BIOS
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105295:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105298:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010529b:	89 d0                	mov    %edx,%eax
c010529d:	c1 e0 02             	shl    $0x2,%eax
c01052a0:	01 d0                	add    %edx,%eax
c01052a2:	c1 e0 02             	shl    $0x2,%eax
c01052a5:	01 c8                	add    %ecx,%eax
c01052a7:	8b 50 08             	mov    0x8(%eax),%edx
c01052aa:	8b 40 04             	mov    0x4(%eax),%eax
c01052ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01052b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01052b3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01052b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052b9:	89 d0                	mov    %edx,%eax
c01052bb:	c1 e0 02             	shl    $0x2,%eax
c01052be:	01 d0                	add    %edx,%eax
c01052c0:	c1 e0 02             	shl    $0x2,%eax
c01052c3:	01 c8                	add    %ecx,%eax
c01052c5:	8b 48 0c             	mov    0xc(%eax),%ecx
c01052c8:	8b 58 10             	mov    0x10(%eax),%ebx
c01052cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01052ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052d1:	01 c8                	add    %ecx,%eax
c01052d3:	11 da                	adc    %ebx,%edx
c01052d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01052d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01052db:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01052de:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052e1:	89 d0                	mov    %edx,%eax
c01052e3:	c1 e0 02             	shl    $0x2,%eax
c01052e6:	01 d0                	add    %edx,%eax
c01052e8:	c1 e0 02             	shl    $0x2,%eax
c01052eb:	01 c8                	add    %ecx,%eax
c01052ed:	83 c0 14             	add    $0x14,%eax
c01052f0:	8b 00                	mov    (%eax),%eax
c01052f2:	83 f8 01             	cmp    $0x1,%eax
c01052f5:	0f 85 e9 00 00 00    	jne    c01053e4 <page_init+0x372>
            // these two ifs are correct the boundary
            if (begin < freemem) {
c01052fb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01052fe:	ba 00 00 00 00       	mov    $0x0,%edx
c0105303:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105306:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105309:	19 d1                	sbb    %edx,%ecx
c010530b:	73 0d                	jae    c010531a <page_init+0x2a8>
                begin = freemem;
c010530d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105310:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105313:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010531a:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010531f:	b8 00 00 00 00       	mov    $0x0,%eax
c0105324:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0105327:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c010532a:	73 0e                	jae    c010533a <page_init+0x2c8>
                end = KMEMSIZE;
c010532c:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0105333:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            // correct the boundary and call init_memmap(), that is to say,
            // the default_init_memmap(), whose args are block_size and PageNum.
            // only the blocks over the freemem can be init
            if (begin < end) {
c010533a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010533d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105340:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105343:	89 d0                	mov    %edx,%eax
c0105345:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105348:	0f 83 96 00 00 00    	jae    c01053e4 <page_init+0x372>
                begin = ROUNDUP(begin, PGSIZE);
c010534e:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0105355:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105358:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010535b:	01 d0                	add    %edx,%eax
c010535d:	83 e8 01             	sub    $0x1,%eax
c0105360:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0105363:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105366:	ba 00 00 00 00       	mov    $0x0,%edx
c010536b:	f7 75 b0             	divl   -0x50(%ebp)
c010536e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105371:	29 d0                	sub    %edx,%eax
c0105373:	ba 00 00 00 00       	mov    $0x0,%edx
c0105378:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010537b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010537e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105381:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0105384:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105387:	ba 00 00 00 00       	mov    $0x0,%edx
c010538c:	89 c3                	mov    %eax,%ebx
c010538e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0105394:	89 de                	mov    %ebx,%esi
c0105396:	89 d0                	mov    %edx,%eax
c0105398:	83 e0 00             	and    $0x0,%eax
c010539b:	89 c7                	mov    %eax,%edi
c010539d:	89 75 c8             	mov    %esi,-0x38(%ebp)
c01053a0:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c01053a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053a9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01053ac:	89 d0                	mov    %edx,%eax
c01053ae:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01053b1:	73 31                	jae    c01053e4 <page_init+0x372>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01053b3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01053b6:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01053b9:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01053bc:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01053bf:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01053c3:	c1 ea 0c             	shr    $0xc,%edx
c01053c6:	89 c3                	mov    %eax,%ebx
c01053c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053cb:	83 ec 0c             	sub    $0xc,%esp
c01053ce:	50                   	push   %eax
c01053cf:	e8 e7 f8 ff ff       	call   c0104cbb <pa2page>
c01053d4:	83 c4 10             	add    $0x10,%esp
c01053d7:	83 ec 08             	sub    $0x8,%esp
c01053da:	53                   	push   %ebx
c01053db:	50                   	push   %eax
c01053dc:	e8 a3 fb ff ff       	call   c0104f84 <init_memmap>
c01053e1:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < memmap->nr_map; i++) {
c01053e4:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01053e8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01053eb:	8b 00                	mov    (%eax),%eax
c01053ed:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01053f0:	0f 8c 9f fe ff ff    	jl     c0105295 <page_init+0x223>
                }
            }
        }
    }
}
c01053f6:	90                   	nop
c01053f7:	90                   	nop
c01053f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01053fb:	5b                   	pop    %ebx
c01053fc:	5e                   	pop    %esi
c01053fd:	5f                   	pop    %edi
c01053fe:	5d                   	pop    %ebp
c01053ff:	c3                   	ret    

c0105400 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0105400:	55                   	push   %ebp
c0105401:	89 e5                	mov    %esp,%ebp
c0105403:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0105406:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105409:	33 45 14             	xor    0x14(%ebp),%eax
c010540c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105411:	85 c0                	test   %eax,%eax
c0105413:	74 19                	je     c010542e <boot_map_segment+0x2e>
c0105415:	68 f6 c3 10 c0       	push   $0xc010c3f6
c010541a:	68 0d c4 10 c0       	push   $0xc010c40d
c010541f:	68 11 01 00 00       	push   $0x111
c0105424:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105429:	e8 58 b9 ff ff       	call   c0100d86 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010542e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0105435:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105438:	25 ff 0f 00 00       	and    $0xfff,%eax
c010543d:	89 c2                	mov    %eax,%edx
c010543f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105442:	01 c2                	add    %eax,%edx
c0105444:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105447:	01 d0                	add    %edx,%eax
c0105449:	83 e8 01             	sub    $0x1,%eax
c010544c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010544f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105452:	ba 00 00 00 00       	mov    $0x0,%edx
c0105457:	f7 75 f0             	divl   -0x10(%ebp)
c010545a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010545d:	29 d0                	sub    %edx,%eax
c010545f:	c1 e8 0c             	shr    $0xc,%eax
c0105462:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0105465:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105468:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010546b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010546e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105473:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0105476:	8b 45 14             	mov    0x14(%ebp),%eax
c0105479:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010547c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010547f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105484:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE) {
c0105487:	eb 57                	jmp    c01054e0 <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0105489:	83 ec 04             	sub    $0x4,%esp
c010548c:	6a 01                	push   $0x1
c010548e:	ff 75 0c             	pushl  0xc(%ebp)
c0105491:	ff 75 08             	pushl  0x8(%ebp)
c0105494:	e8 59 01 00 00       	call   c01055f2 <get_pte>
c0105499:	83 c4 10             	add    $0x10,%esp
c010549c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010549f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01054a3:	75 19                	jne    c01054be <boot_map_segment+0xbe>
c01054a5:	68 22 c4 10 c0       	push   $0xc010c422
c01054aa:	68 0d c4 10 c0       	push   $0xc010c40d
c01054af:	68 17 01 00 00       	push   $0x117
c01054b4:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01054b9:	e8 c8 b8 ff ff       	call   c0100d86 <__panic>
        *ptep = pa | PTE_P | perm;
c01054be:	8b 45 14             	mov    0x14(%ebp),%eax
c01054c1:	0b 45 18             	or     0x18(%ebp),%eax
c01054c4:	83 c8 01             	or     $0x1,%eax
c01054c7:	89 c2                	mov    %eax,%edx
c01054c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054cc:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE) {
c01054ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01054d2:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01054d9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01054e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01054e4:	75 a3                	jne    c0105489 <boot_map_segment+0x89>
    }
}
c01054e6:	90                   	nop
c01054e7:	90                   	nop
c01054e8:	c9                   	leave  
c01054e9:	c3                   	ret    

c01054ea <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01054ea:	55                   	push   %ebp
c01054eb:	89 e5                	mov    %esp,%ebp
c01054ed:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c01054f0:	83 ec 0c             	sub    $0xc,%esp
c01054f3:	6a 01                	push   $0x1
c01054f5:	e8 a9 fa ff ff       	call   c0104fa3 <alloc_pages>
c01054fa:	83 c4 10             	add    $0x10,%esp
c01054fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0105500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105504:	75 17                	jne    c010551d <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c0105506:	83 ec 04             	sub    $0x4,%esp
c0105509:	68 2f c4 10 c0       	push   $0xc010c42f
c010550e:	68 23 01 00 00       	push   $0x123
c0105513:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105518:	e8 69 b8 ff ff       	call   c0100d86 <__panic>
    }
    return page2kva(p);
c010551d:	83 ec 0c             	sub    $0xc,%esp
c0105520:	ff 75 f4             	pushl  -0xc(%ebp)
c0105523:	e8 d1 f7 ff ff       	call   c0104cf9 <page2kva>
c0105528:	83 c4 10             	add    $0x10,%esp
}
c010552b:	c9                   	leave  
c010552c:	c3                   	ret    

c010552d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010552d:	55                   	push   %ebp
c010552e:	89 e5                	mov    %esp,%ebp
c0105530:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0105533:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105538:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010553b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105542:	77 17                	ja     c010555b <pmm_init+0x2e>
c0105544:	ff 75 f4             	pushl  -0xc(%ebp)
c0105547:	68 c4 c3 10 c0       	push   $0xc010c3c4
c010554c:	68 2d 01 00 00       	push   $0x12d
c0105551:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105556:	e8 2b b8 ff ff       	call   c0100d86 <__panic>
c010555b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010555e:	05 00 00 00 40       	add    $0x40000000,%eax
c0105563:	a3 a8 3f 1a c0       	mov    %eax,0xc01a3fa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0105568:	e8 e2 f9 ff ff       	call   c0104f4f <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010556d:	e8 00 fb ff ff       	call   c0105072 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0105572:	e8 ef 07 00 00       	call   c0105d66 <check_alloc_page>

    check_pgdir();
c0105577:	e8 0d 08 00 00       	call   c0105d89 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010557c:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105581:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105584:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010558b:	77 17                	ja     c01055a4 <pmm_init+0x77>
c010558d:	ff 75 f0             	pushl  -0x10(%ebp)
c0105590:	68 c4 c3 10 c0       	push   $0xc010c3c4
c0105595:	68 43 01 00 00       	push   $0x143
c010559a:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010559f:	e8 e2 b7 ff ff       	call   c0100d86 <__panic>
c01055a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055a7:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01055ad:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01055b2:	05 ac 0f 00 00       	add    $0xfac,%eax
c01055b7:	83 ca 03             	or     $0x3,%edx
c01055ba:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01055bc:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01055c1:	83 ec 0c             	sub    $0xc,%esp
c01055c4:	6a 02                	push   $0x2
c01055c6:	6a 00                	push   $0x0
c01055c8:	68 00 00 00 38       	push   $0x38000000
c01055cd:	68 00 00 00 c0       	push   $0xc0000000
c01055d2:	50                   	push   %eax
c01055d3:	e8 28 fe ff ff       	call   c0105400 <boot_map_segment>
c01055d8:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01055db:	e8 7c f8 ff ff       	call   c0104e5c <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01055e0:	e8 0a 0d 00 00       	call   c01062ef <check_boot_pgdir>

    print_pgdir();
c01055e5:	e8 00 11 00 00       	call   c01066ea <print_pgdir>

    kmalloc_init();
c01055ea:	e8 00 f4 ff ff       	call   c01049ef <kmalloc_init>
}
c01055ef:	90                   	nop
c01055f0:	c9                   	leave  
c01055f1:	c3                   	ret    

c01055f2 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01055f2:	55                   	push   %ebp
c01055f3:	89 e5                	mov    %esp,%ebp
c01055f5:	83 ec 28             	sub    $0x28,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = PDX(la) + pgdir;  // (1) find page directory entry
c01055f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01055fb:	c1 e8 16             	shr    $0x16,%eax
c01055fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105605:	8b 45 08             	mov    0x8(%ebp),%eax
c0105608:	01 d0                	add    %edx,%eax
c010560a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // (2) check if entry is not present
c010560d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105610:	8b 00                	mov    (%eax),%eax
c0105612:	83 e0 01             	and    $0x1,%eax
c0105615:	85 c0                	test   %eax,%eax
c0105617:	0f 85 9f 00 00 00    	jne    c01056bc <get_pte+0xca>
        // (4) set page reference
        // (5) get linear address of page
        // (6) clear page content using memset
        // (7) set page directory entry's permission
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c010561d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105621:	74 16                	je     c0105639 <get_pte+0x47>
c0105623:	83 ec 0c             	sub    $0xc,%esp
c0105626:	6a 01                	push   $0x1
c0105628:	e8 76 f9 ff ff       	call   c0104fa3 <alloc_pages>
c010562d:	83 c4 10             	add    $0x10,%esp
c0105630:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105633:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105637:	75 0a                	jne    c0105643 <get_pte+0x51>
            return NULL;
c0105639:	b8 00 00 00 00       	mov    $0x0,%eax
c010563e:	e9 d0 00 00 00       	jmp    c0105713 <get_pte+0x121>
        }
        set_page_ref(page, 1);
c0105643:	83 ec 08             	sub    $0x8,%esp
c0105646:	6a 01                	push   $0x1
c0105648:	ff 75 f0             	pushl  -0x10(%ebp)
c010564b:	e8 4e f7 ff ff       	call   c0104d9e <set_page_ref>
c0105650:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);  // the physical address of page table
c0105653:	83 ec 0c             	sub    $0xc,%esp
c0105656:	ff 75 f0             	pushl  -0x10(%ebp)
c0105659:	e8 4a f6 ff ff       	call   c0104ca8 <page2pa>
c010565e:	83 c4 10             	add    $0x10,%esp
c0105661:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0105664:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105667:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010566a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010566d:	c1 e8 0c             	shr    $0xc,%eax
c0105670:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105673:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0105678:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010567b:	72 17                	jb     c0105694 <get_pte+0xa2>
c010567d:	ff 75 e8             	pushl  -0x18(%ebp)
c0105680:	68 20 c3 10 c0       	push   $0xc010c320
c0105685:	68 85 01 00 00       	push   $0x185
c010568a:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010568f:	e8 f2 b6 ff ff       	call   c0100d86 <__panic>
c0105694:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105697:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010569c:	83 ec 04             	sub    $0x4,%esp
c010569f:	68 00 10 00 00       	push   $0x1000
c01056a4:	6a 00                	push   $0x0
c01056a6:	50                   	push   %eax
c01056a7:	e8 38 5c 00 00       	call   c010b2e4 <memset>
c01056ac:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_P | PTE_W | PTE_U;
c01056af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01056b2:	83 c8 07             	or     $0x7,%eax
c01056b5:	89 c2                	mov    %eax,%edx
c01056b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056ba:	89 10                	mov    %edx,(%eax)
    }

    pte_t *ptep = (pte_t *)KADDR(PDE_ADDR(*pdep)) + PTX(la);
c01056bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056bf:	8b 00                	mov    (%eax),%eax
c01056c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01056c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01056c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056cc:	c1 e8 0c             	shr    $0xc,%eax
c01056cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01056d2:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01056d7:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01056da:	72 17                	jb     c01056f3 <get_pte+0x101>
c01056dc:	ff 75 e0             	pushl  -0x20(%ebp)
c01056df:	68 20 c3 10 c0       	push   $0xc010c320
c01056e4:	68 89 01 00 00       	push   $0x189
c01056e9:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01056ee:	e8 93 b6 ff ff       	call   c0100d86 <__panic>
c01056f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01056fb:	89 c2                	mov    %eax,%edx
c01056fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105700:	c1 e8 0c             	shr    $0xc,%eax
c0105703:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105708:	c1 e0 02             	shl    $0x2,%eax
c010570b:	01 d0                	add    %edx,%eax
c010570d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return ptep;  // (8) return page table entry
c0105710:	8b 45 d8             	mov    -0x28(%ebp),%eax
#endif
}
c0105713:	c9                   	leave  
c0105714:	c3                   	ret    

c0105715 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105715:	55                   	push   %ebp
c0105716:	89 e5                	mov    %esp,%ebp
c0105718:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010571b:	83 ec 04             	sub    $0x4,%esp
c010571e:	6a 00                	push   $0x0
c0105720:	ff 75 0c             	pushl  0xc(%ebp)
c0105723:	ff 75 08             	pushl  0x8(%ebp)
c0105726:	e8 c7 fe ff ff       	call   c01055f2 <get_pte>
c010572b:	83 c4 10             	add    $0x10,%esp
c010572e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0105731:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105735:	74 08                	je     c010573f <get_page+0x2a>
        *ptep_store = ptep;
c0105737:	8b 45 10             	mov    0x10(%ebp),%eax
c010573a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010573d:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010573f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105743:	74 1f                	je     c0105764 <get_page+0x4f>
c0105745:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105748:	8b 00                	mov    (%eax),%eax
c010574a:	83 e0 01             	and    $0x1,%eax
c010574d:	85 c0                	test   %eax,%eax
c010574f:	74 13                	je     c0105764 <get_page+0x4f>
        return pte2page(*ptep);
c0105751:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105754:	8b 00                	mov    (%eax),%eax
c0105756:	83 ec 0c             	sub    $0xc,%esp
c0105759:	50                   	push   %eax
c010575a:	e8 df f5 ff ff       	call   c0104d3e <pte2page>
c010575f:	83 c4 10             	add    $0x10,%esp
c0105762:	eb 05                	jmp    c0105769 <get_page+0x54>
    }
    return NULL;
c0105764:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105769:	c9                   	leave  
c010576a:	c3                   	ret    

c010576b <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010576b:	55                   	push   %ebp
c010576c:	89 e5                	mov    %esp,%ebp
c010576e:	83 ec 18             	sub    $0x18,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
    if (*ptep & PTE_P)  //(1) check if this page table entry is present
c0105771:	8b 45 10             	mov    0x10(%ebp),%eax
c0105774:	8b 00                	mov    (%eax),%eax
c0105776:	83 e0 01             	and    $0x1,%eax
c0105779:	85 c0                	test   %eax,%eax
c010577b:	74 50                	je     c01057cd <page_remove_pte+0x62>
    {
        struct Page *page = pte2page(*ptep);  //(2) find corresponding page to pte
c010577d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105780:	8b 00                	mov    (%eax),%eax
c0105782:	83 ec 0c             	sub    $0xc,%esp
c0105785:	50                   	push   %eax
c0105786:	e8 b3 f5 ff ff       	call   c0104d3e <pte2page>
c010578b:	83 c4 10             	add    $0x10,%esp
c010578e:	89 45 f4             	mov    %eax,-0xc(%ebp)

        if (page_ref_dec(page) == 0)  //(3) decrease page reference
c0105791:	83 ec 0c             	sub    $0xc,%esp
c0105794:	ff 75 f4             	pushl  -0xc(%ebp)
c0105797:	e8 27 f6 ff ff       	call   c0104dc3 <page_ref_dec>
c010579c:	83 c4 10             	add    $0x10,%esp
c010579f:	85 c0                	test   %eax,%eax
c01057a1:	75 10                	jne    c01057b3 <page_remove_pte+0x48>
        {                             //free_page means add this page to freeList in FIFO
            free_page(page);          //(4) and free this page when page reference reachs 0
c01057a3:	83 ec 08             	sub    $0x8,%esp
c01057a6:	6a 01                	push   $0x1
c01057a8:	ff 75 f4             	pushl  -0xc(%ebp)
c01057ab:	e8 5f f8 ff ff       	call   c010500f <free_pages>
c01057b0:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;                  //(5) clear second page table entry
c01057b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01057b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);  //(6) flush tlb
c01057bc:	83 ec 08             	sub    $0x8,%esp
c01057bf:	ff 75 0c             	pushl  0xc(%ebp)
c01057c2:	ff 75 08             	pushl  0x8(%ebp)
c01057c5:	e8 9a 04 00 00       	call   c0105c64 <tlb_invalidate>
c01057ca:	83 c4 10             	add    $0x10,%esp
    }
#endif
}
c01057cd:	90                   	nop
c01057ce:	c9                   	leave  
c01057cf:	c3                   	ret    

c01057d0 <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c01057d0:	55                   	push   %ebp
c01057d1:	89 e5                	mov    %esp,%ebp
c01057d3:	83 ec 18             	sub    $0x18,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c01057d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057d9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01057de:	85 c0                	test   %eax,%eax
c01057e0:	75 0c                	jne    c01057ee <unmap_range+0x1e>
c01057e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01057e5:	25 ff 0f 00 00       	and    $0xfff,%eax
c01057ea:	85 c0                	test   %eax,%eax
c01057ec:	74 19                	je     c0105807 <unmap_range+0x37>
c01057ee:	68 48 c4 10 c0       	push   $0xc010c448
c01057f3:	68 0d c4 10 c0       	push   $0xc010c40d
c01057f8:	68 c1 01 00 00       	push   $0x1c1
c01057fd:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105802:	e8 7f b5 ff ff       	call   c0100d86 <__panic>
    assert(USER_ACCESS(start, end));
c0105807:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010580e:	76 11                	jbe    c0105821 <unmap_range+0x51>
c0105810:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105813:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105816:	73 09                	jae    c0105821 <unmap_range+0x51>
c0105818:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c010581f:	76 19                	jbe    c010583a <unmap_range+0x6a>
c0105821:	68 71 c4 10 c0       	push   $0xc010c471
c0105826:	68 0d c4 10 c0       	push   $0xc010c40d
c010582b:	68 c2 01 00 00       	push   $0x1c2
c0105830:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105835:	e8 4c b5 ff ff       	call   c0100d86 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c010583a:	83 ec 04             	sub    $0x4,%esp
c010583d:	6a 00                	push   $0x0
c010583f:	ff 75 0c             	pushl  0xc(%ebp)
c0105842:	ff 75 08             	pushl  0x8(%ebp)
c0105845:	e8 a8 fd ff ff       	call   c01055f2 <get_pte>
c010584a:	83 c4 10             	add    $0x10,%esp
c010584d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105850:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105854:	75 18                	jne    c010586e <unmap_range+0x9e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105856:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105859:	05 00 00 40 00       	add    $0x400000,%eax
c010585e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105861:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105864:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105869:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue;
c010586c:	eb 24                	jmp    c0105892 <unmap_range+0xc2>
        }
        if (*ptep != 0) {
c010586e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105871:	8b 00                	mov    (%eax),%eax
c0105873:	85 c0                	test   %eax,%eax
c0105875:	74 14                	je     c010588b <unmap_range+0xbb>
            page_remove_pte(pgdir, start, ptep);
c0105877:	83 ec 04             	sub    $0x4,%esp
c010587a:	ff 75 f4             	pushl  -0xc(%ebp)
c010587d:	ff 75 0c             	pushl  0xc(%ebp)
c0105880:	ff 75 08             	pushl  0x8(%ebp)
c0105883:	e8 e3 fe ff ff       	call   c010576b <page_remove_pte>
c0105888:	83 c4 10             	add    $0x10,%esp
        }
        start += PGSIZE;
c010588b:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105892:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105896:	74 08                	je     c01058a0 <unmap_range+0xd0>
c0105898:	8b 45 0c             	mov    0xc(%ebp),%eax
c010589b:	3b 45 10             	cmp    0x10(%ebp),%eax
c010589e:	72 9a                	jb     c010583a <unmap_range+0x6a>
}
c01058a0:	90                   	nop
c01058a1:	c9                   	leave  
c01058a2:	c3                   	ret    

c01058a3 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c01058a3:	55                   	push   %ebp
c01058a4:	89 e5                	mov    %esp,%ebp
c01058a6:	83 ec 18             	sub    $0x18,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c01058a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058ac:	25 ff 0f 00 00       	and    $0xfff,%eax
c01058b1:	85 c0                	test   %eax,%eax
c01058b3:	75 0c                	jne    c01058c1 <exit_range+0x1e>
c01058b5:	8b 45 10             	mov    0x10(%ebp),%eax
c01058b8:	25 ff 0f 00 00       	and    $0xfff,%eax
c01058bd:	85 c0                	test   %eax,%eax
c01058bf:	74 19                	je     c01058da <exit_range+0x37>
c01058c1:	68 48 c4 10 c0       	push   $0xc010c448
c01058c6:	68 0d c4 10 c0       	push   $0xc010c40d
c01058cb:	68 d3 01 00 00       	push   $0x1d3
c01058d0:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01058d5:	e8 ac b4 ff ff       	call   c0100d86 <__panic>
    assert(USER_ACCESS(start, end));
c01058da:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c01058e1:	76 11                	jbe    c01058f4 <exit_range+0x51>
c01058e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058e6:	3b 45 10             	cmp    0x10(%ebp),%eax
c01058e9:	73 09                	jae    c01058f4 <exit_range+0x51>
c01058eb:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c01058f2:	76 19                	jbe    c010590d <exit_range+0x6a>
c01058f4:	68 71 c4 10 c0       	push   $0xc010c471
c01058f9:	68 0d c4 10 c0       	push   $0xc010c40d
c01058fe:	68 d4 01 00 00       	push   $0x1d4
c0105903:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105908:	e8 79 b4 ff ff       	call   c0100d86 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c010590d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105910:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105913:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105916:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c010591b:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {  //exit_range by page unit
        int pde_idx = PDX(start);
c010591e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105921:	c1 e8 16             	shr    $0x16,%eax
c0105924:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105927:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010592a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105931:	8b 45 08             	mov    0x8(%ebp),%eax
c0105934:	01 d0                	add    %edx,%eax
c0105936:	8b 00                	mov    (%eax),%eax
c0105938:	83 e0 01             	and    $0x1,%eax
c010593b:	85 c0                	test   %eax,%eax
c010593d:	74 40                	je     c010597f <exit_range+0xdc>
            free_page(pde2page(pgdir[pde_idx]));
c010593f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105942:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105949:	8b 45 08             	mov    0x8(%ebp),%eax
c010594c:	01 d0                	add    %edx,%eax
c010594e:	8b 00                	mov    (%eax),%eax
c0105950:	83 ec 0c             	sub    $0xc,%esp
c0105953:	50                   	push   %eax
c0105954:	e8 1f f4 ff ff       	call   c0104d78 <pde2page>
c0105959:	83 c4 10             	add    $0x10,%esp
c010595c:	83 ec 08             	sub    $0x8,%esp
c010595f:	6a 01                	push   $0x1
c0105961:	50                   	push   %eax
c0105962:	e8 a8 f6 ff ff       	call   c010500f <free_pages>
c0105967:	83 c4 10             	add    $0x10,%esp
            pgdir[pde_idx] = 0;
c010596a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010596d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105974:	8b 45 08             	mov    0x8(%ebp),%eax
c0105977:	01 d0                	add    %edx,%eax
c0105979:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c010597f:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105986:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010598a:	74 08                	je     c0105994 <exit_range+0xf1>
c010598c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010598f:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105992:	72 8a                	jb     c010591e <exit_range+0x7b>
}
c0105994:	90                   	nop
c0105995:	c9                   	leave  
c0105996:	c3                   	ret    

c0105997 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105997:	55                   	push   %ebp
c0105998:	89 e5                	mov    %esp,%ebp
c010599a:	83 ec 38             	sub    $0x38,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c010599d:	8b 45 10             	mov    0x10(%ebp),%eax
c01059a0:	25 ff 0f 00 00       	and    $0xfff,%eax
c01059a5:	85 c0                	test   %eax,%eax
c01059a7:	75 0c                	jne    c01059b5 <copy_range+0x1e>
c01059a9:	8b 45 14             	mov    0x14(%ebp),%eax
c01059ac:	25 ff 0f 00 00       	and    $0xfff,%eax
c01059b1:	85 c0                	test   %eax,%eax
c01059b3:	74 19                	je     c01059ce <copy_range+0x37>
c01059b5:	68 48 c4 10 c0       	push   $0xc010c448
c01059ba:	68 0d c4 10 c0       	push   $0xc010c40d
c01059bf:	68 e9 01 00 00       	push   $0x1e9
c01059c4:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01059c9:	e8 b8 b3 ff ff       	call   c0100d86 <__panic>
    assert(USER_ACCESS(start, end));
c01059ce:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c01059d5:	76 11                	jbe    c01059e8 <copy_range+0x51>
c01059d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01059da:	3b 45 14             	cmp    0x14(%ebp),%eax
c01059dd:	73 09                	jae    c01059e8 <copy_range+0x51>
c01059df:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c01059e6:	76 19                	jbe    c0105a01 <copy_range+0x6a>
c01059e8:	68 71 c4 10 c0       	push   $0xc010c471
c01059ed:	68 0d c4 10 c0       	push   $0xc010c40d
c01059f2:	68 ea 01 00 00       	push   $0x1ea
c01059f7:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01059fc:	e8 85 b3 ff ff       	call   c0100d86 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;  // nptep for new page table entry pointer
c0105a01:	83 ec 04             	sub    $0x4,%esp
c0105a04:	6a 00                	push   $0x0
c0105a06:	ff 75 10             	pushl  0x10(%ebp)
c0105a09:	ff 75 0c             	pushl  0xc(%ebp)
c0105a0c:	e8 e1 fb ff ff       	call   c01055f2 <get_pte>
c0105a11:	83 c4 10             	add    $0x10,%esp
c0105a14:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105a17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a1b:	75 1b                	jne    c0105a38 <copy_range+0xa1>
            // why would this happen?
            // PTSIZE : bytes mapped by a page directory entry
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105a1d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a20:	05 00 00 40 00       	add    $0x400000,%eax
c0105a25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105a28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105a2b:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105a30:	89 45 10             	mov    %eax,0x10(%ebp)
            continue;
c0105a33:	e9 21 01 00 00       	jmp    c0105b59 <copy_range+0x1c2>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a3b:	8b 00                	mov    (%eax),%eax
c0105a3d:	83 e0 01             	and    $0x1,%eax
c0105a40:	85 c0                	test   %eax,%eax
c0105a42:	0f 84 0a 01 00 00    	je     c0105b52 <copy_range+0x1bb>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105a48:	83 ec 04             	sub    $0x4,%esp
c0105a4b:	6a 01                	push   $0x1
c0105a4d:	ff 75 10             	pushl  0x10(%ebp)
c0105a50:	ff 75 08             	pushl  0x8(%ebp)
c0105a53:	e8 9a fb ff ff       	call   c01055f2 <get_pte>
c0105a58:	83 c4 10             	add    $0x10,%esp
c0105a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105a62:	75 0a                	jne    c0105a6e <copy_range+0xd7>
                return -E_NO_MEM;
c0105a64:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105a69:	e9 02 01 00 00       	jmp    c0105b70 <copy_range+0x1d9>
            }
            uint32_t perm = (*ptep & PTE_USER);
c0105a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a71:	8b 00                	mov    (%eax),%eax
c0105a73:	83 e0 07             	and    $0x7,%eax
c0105a76:	89 45 ec             	mov    %eax,-0x14(%ebp)
            //get page from ptep
            struct Page *page = pte2page(*ptep);
c0105a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a7c:	8b 00                	mov    (%eax),%eax
c0105a7e:	83 ec 0c             	sub    $0xc,%esp
c0105a81:	50                   	push   %eax
c0105a82:	e8 b7 f2 ff ff       	call   c0104d3e <pte2page>
c0105a87:	83 c4 10             	add    $0x10,%esp
c0105a8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
            // alloc a page for process B
            struct Page *npage = alloc_page();
c0105a8d:	83 ec 0c             	sub    $0xc,%esp
c0105a90:	6a 01                	push   $0x1
c0105a92:	e8 0c f5 ff ff       	call   c0104fa3 <alloc_pages>
c0105a97:	83 c4 10             	add    $0x10,%esp
c0105a9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            assert(page != NULL);
c0105a9d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105aa1:	75 19                	jne    c0105abc <copy_range+0x125>
c0105aa3:	68 89 c4 10 c0       	push   $0xc010c489
c0105aa8:	68 0d c4 10 c0       	push   $0xc010c40d
c0105aad:	68 ff 01 00 00       	push   $0x1ff
c0105ab2:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105ab7:	e8 ca b2 ff ff       	call   c0100d86 <__panic>
            assert(npage != NULL);
c0105abc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ac0:	75 19                	jne    c0105adb <copy_range+0x144>
c0105ac2:	68 96 c4 10 c0       	push   $0xc010c496
c0105ac7:	68 0d c4 10 c0       	push   $0xc010c40d
c0105acc:	68 00 02 00 00       	push   $0x200
c0105ad1:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105ad6:	e8 ab b2 ff ff       	call   c0100d86 <__panic>
            int ret = 0;
c0105adb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
            uintptr_t src_kvaddr, dst_kvaddr;
            src_kvaddr = page2kva(page);
c0105ae2:	83 ec 0c             	sub    $0xc,%esp
c0105ae5:	ff 75 e8             	pushl  -0x18(%ebp)
c0105ae8:	e8 0c f2 ff ff       	call   c0104cf9 <page2kva>
c0105aed:	83 c4 10             	add    $0x10,%esp
c0105af0:	89 45 dc             	mov    %eax,-0x24(%ebp)
            dst_kvaddr = page2kva(npage);
c0105af3:	83 ec 0c             	sub    $0xc,%esp
c0105af6:	ff 75 e4             	pushl  -0x1c(%ebp)
c0105af9:	e8 fb f1 ff ff       	call   c0104cf9 <page2kva>
c0105afe:	83 c4 10             	add    $0x10,%esp
c0105b01:	89 45 d8             	mov    %eax,-0x28(%ebp)
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
c0105b04:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105b07:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105b0a:	83 ec 04             	sub    $0x4,%esp
c0105b0d:	68 00 10 00 00       	push   $0x1000
c0105b12:	52                   	push   %edx
c0105b13:	50                   	push   %eax
c0105b14:	e8 ac 58 00 00       	call   c010b3c5 <memcpy>
c0105b19:	83 c4 10             	add    $0x10,%esp
            ret = page_insert(to, npage, start, perm);
c0105b1c:	ff 75 ec             	pushl  -0x14(%ebp)
c0105b1f:	ff 75 10             	pushl  0x10(%ebp)
c0105b22:	ff 75 e4             	pushl  -0x1c(%ebp)
c0105b25:	ff 75 08             	pushl  0x8(%ebp)
c0105b28:	e8 7e 00 00 00       	call   c0105bab <page_insert>
c0105b2d:	83 c4 10             	add    $0x10,%esp
c0105b30:	89 45 e0             	mov    %eax,-0x20(%ebp)
            assert(ret == 0);
c0105b33:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105b37:	74 19                	je     c0105b52 <copy_range+0x1bb>
c0105b39:	68 a4 c4 10 c0       	push   $0xc010c4a4
c0105b3e:	68 0d c4 10 c0       	push   $0xc010c40d
c0105b43:	68 15 02 00 00       	push   $0x215
c0105b48:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105b4d:	e8 34 b2 ff ff       	call   c0100d86 <__panic>
        }
        start += PGSIZE;
c0105b52:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105b59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b5d:	74 0c                	je     c0105b6b <copy_range+0x1d4>
c0105b5f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b62:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105b65:	0f 82 96 fe ff ff    	jb     c0105a01 <copy_range+0x6a>
    return 0;
c0105b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b70:	c9                   	leave  
c0105b71:	c3                   	ret    

c0105b72 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105b72:	55                   	push   %ebp
c0105b73:	89 e5                	mov    %esp,%ebp
c0105b75:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105b78:	83 ec 04             	sub    $0x4,%esp
c0105b7b:	6a 00                	push   $0x0
c0105b7d:	ff 75 0c             	pushl  0xc(%ebp)
c0105b80:	ff 75 08             	pushl  0x8(%ebp)
c0105b83:	e8 6a fa ff ff       	call   c01055f2 <get_pte>
c0105b88:	83 c4 10             	add    $0x10,%esp
c0105b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105b8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105b92:	74 14                	je     c0105ba8 <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c0105b94:	83 ec 04             	sub    $0x4,%esp
c0105b97:	ff 75 f4             	pushl  -0xc(%ebp)
c0105b9a:	ff 75 0c             	pushl  0xc(%ebp)
c0105b9d:	ff 75 08             	pushl  0x8(%ebp)
c0105ba0:	e8 c6 fb ff ff       	call   c010576b <page_remove_pte>
c0105ba5:	83 c4 10             	add    $0x10,%esp
    }
}
c0105ba8:	90                   	nop
c0105ba9:	c9                   	leave  
c0105baa:	c3                   	ret    

c0105bab <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105bab:	55                   	push   %ebp
c0105bac:	89 e5                	mov    %esp,%ebp
c0105bae:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105bb1:	83 ec 04             	sub    $0x4,%esp
c0105bb4:	6a 01                	push   $0x1
c0105bb6:	ff 75 10             	pushl  0x10(%ebp)
c0105bb9:	ff 75 08             	pushl  0x8(%ebp)
c0105bbc:	e8 31 fa ff ff       	call   c01055f2 <get_pte>
c0105bc1:	83 c4 10             	add    $0x10,%esp
c0105bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105bc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105bcb:	75 0a                	jne    c0105bd7 <page_insert+0x2c>
        return -E_NO_MEM;
c0105bcd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105bd2:	e9 8b 00 00 00       	jmp    c0105c62 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105bd7:	83 ec 0c             	sub    $0xc,%esp
c0105bda:	ff 75 0c             	pushl  0xc(%ebp)
c0105bdd:	e8 ca f1 ff ff       	call   c0104dac <page_ref_inc>
c0105be2:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {  //the pte is not empty
c0105be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105be8:	8b 00                	mov    (%eax),%eax
c0105bea:	83 e0 01             	and    $0x1,%eax
c0105bed:	85 c0                	test   %eax,%eax
c0105bef:	74 40                	je     c0105c31 <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c0105bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bf4:	8b 00                	mov    (%eax),%eax
c0105bf6:	83 ec 0c             	sub    $0xc,%esp
c0105bf9:	50                   	push   %eax
c0105bfa:	e8 3f f1 ff ff       	call   c0104d3e <pte2page>
c0105bff:	83 c4 10             	add    $0x10,%esp
c0105c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c08:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105c0b:	75 10                	jne    c0105c1d <page_insert+0x72>
            page_ref_dec(page);  // used to modify the pages permission(?)
c0105c0d:	83 ec 0c             	sub    $0xc,%esp
c0105c10:	ff 75 0c             	pushl  0xc(%ebp)
c0105c13:	e8 ab f1 ff ff       	call   c0104dc3 <page_ref_dec>
c0105c18:	83 c4 10             	add    $0x10,%esp
c0105c1b:	eb 14                	jmp    c0105c31 <page_insert+0x86>
        } else {
            page_remove_pte(pgdir, la, ptep);  // if not equal, pte need to be cleaned
c0105c1d:	83 ec 04             	sub    $0x4,%esp
c0105c20:	ff 75 f4             	pushl  -0xc(%ebp)
c0105c23:	ff 75 10             	pushl  0x10(%ebp)
c0105c26:	ff 75 08             	pushl  0x8(%ebp)
c0105c29:	e8 3d fb ff ff       	call   c010576b <page_remove_pte>
c0105c2e:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105c31:	83 ec 0c             	sub    $0xc,%esp
c0105c34:	ff 75 0c             	pushl  0xc(%ebp)
c0105c37:	e8 6c f0 ff ff       	call   c0104ca8 <page2pa>
c0105c3c:	83 c4 10             	add    $0x10,%esp
c0105c3f:	0b 45 14             	or     0x14(%ebp),%eax
c0105c42:	83 c8 01             	or     $0x1,%eax
c0105c45:	89 c2                	mov    %eax,%edx
c0105c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c4a:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105c4c:	83 ec 08             	sub    $0x8,%esp
c0105c4f:	ff 75 10             	pushl  0x10(%ebp)
c0105c52:	ff 75 08             	pushl  0x8(%ebp)
c0105c55:	e8 0a 00 00 00       	call   c0105c64 <tlb_invalidate>
c0105c5a:	83 c4 10             	add    $0x10,%esp
    return 0;
c0105c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c62:	c9                   	leave  
c0105c63:	c3                   	ret    

c0105c64 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105c64:	55                   	push   %ebp
c0105c65:	89 e5                	mov    %esp,%ebp
c0105c67:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105c6a:	0f 20 d8             	mov    %cr3,%eax
c0105c6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105c70:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0105c73:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c76:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c79:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105c80:	77 17                	ja     c0105c99 <tlb_invalidate+0x35>
c0105c82:	ff 75 f4             	pushl  -0xc(%ebp)
c0105c85:	68 c4 c3 10 c0       	push   $0xc010c3c4
c0105c8a:	68 45 02 00 00       	push   $0x245
c0105c8f:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105c94:	e8 ed b0 ff ff       	call   c0100d86 <__panic>
c0105c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c9c:	05 00 00 00 40       	add    $0x40000000,%eax
c0105ca1:	39 d0                	cmp    %edx,%eax
c0105ca3:	75 0d                	jne    c0105cb2 <tlb_invalidate+0x4e>
        invlpg((void *)la);
c0105ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ca8:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105cae:	0f 01 38             	invlpg (%eax)
}
c0105cb1:	90                   	nop
    }
}
c0105cb2:	90                   	nop
c0105cb3:	c9                   	leave  
c0105cb4:	c3                   	ret    

c0105cb5 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0105cb5:	55                   	push   %ebp
c0105cb6:	89 e5                	mov    %esp,%ebp
c0105cb8:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_page();
c0105cbb:	83 ec 0c             	sub    $0xc,%esp
c0105cbe:	6a 01                	push   $0x1
c0105cc0:	e8 de f2 ff ff       	call   c0104fa3 <alloc_pages>
c0105cc5:	83 c4 10             	add    $0x10,%esp
c0105cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105ccb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ccf:	0f 84 8c 00 00 00    	je     c0105d61 <pgdir_alloc_page+0xac>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105cd5:	ff 75 10             	pushl  0x10(%ebp)
c0105cd8:	ff 75 0c             	pushl  0xc(%ebp)
c0105cdb:	ff 75 f4             	pushl  -0xc(%ebp)
c0105cde:	ff 75 08             	pushl  0x8(%ebp)
c0105ce1:	e8 c5 fe ff ff       	call   c0105bab <page_insert>
c0105ce6:	83 c4 10             	add    $0x10,%esp
c0105ce9:	85 c0                	test   %eax,%eax
c0105ceb:	74 17                	je     c0105d04 <pgdir_alloc_page+0x4f>
            free_page(page);
c0105ced:	83 ec 08             	sub    $0x8,%esp
c0105cf0:	6a 01                	push   $0x1
c0105cf2:	ff 75 f4             	pushl  -0xc(%ebp)
c0105cf5:	e8 15 f3 ff ff       	call   c010500f <free_pages>
c0105cfa:	83 c4 10             	add    $0x10,%esp
            return NULL;
c0105cfd:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d02:	eb 60                	jmp    c0105d64 <pgdir_alloc_page+0xaf>
        }
        if (swap_init_ok) {
c0105d04:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c0105d09:	85 c0                	test   %eax,%eax
c0105d0b:	74 54                	je     c0105d61 <pgdir_alloc_page+0xac>
            if (check_mm_struct != NULL) {  //这个really has been modified? only add this condition judgement
c0105d0d:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0105d12:	85 c0                	test   %eax,%eax
c0105d14:	74 4b                	je     c0105d61 <pgdir_alloc_page+0xac>
                swap_map_swappable(check_mm_struct, la, page, 0);
c0105d16:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0105d1b:	6a 00                	push   $0x0
c0105d1d:	ff 75 f4             	pushl  -0xc(%ebp)
c0105d20:	ff 75 0c             	pushl  0xc(%ebp)
c0105d23:	50                   	push   %eax
c0105d24:	e8 56 0c 00 00       	call   c010697f <swap_map_swappable>
c0105d29:	83 c4 10             	add    $0x10,%esp
                page->pra_vaddr = la;
c0105d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d32:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c0105d35:	83 ec 0c             	sub    $0xc,%esp
c0105d38:	ff 75 f4             	pushl  -0xc(%ebp)
c0105d3b:	e8 54 f0 ff ff       	call   c0104d94 <page_ref>
c0105d40:	83 c4 10             	add    $0x10,%esp
c0105d43:	83 f8 01             	cmp    $0x1,%eax
c0105d46:	74 19                	je     c0105d61 <pgdir_alloc_page+0xac>
c0105d48:	68 ad c4 10 c0       	push   $0xc010c4ad
c0105d4d:	68 0d c4 10 c0       	push   $0xc010c40d
c0105d52:	68 59 02 00 00       	push   $0x259
c0105d57:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105d5c:	e8 25 b0 ff ff       	call   c0100d86 <__panic>
                //panic("pgdir_alloc_page: no pages. now current is existed, should fix it in the future\n");
            }
        }
    }

    return page;
c0105d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105d64:	c9                   	leave  
c0105d65:	c3                   	ret    

c0105d66 <check_alloc_page>:

static void
check_alloc_page(void) {
c0105d66:	55                   	push   %ebp
c0105d67:	89 e5                	mov    %esp,%ebp
c0105d69:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c0105d6c:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0105d71:	8b 40 18             	mov    0x18(%eax),%eax
c0105d74:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0105d76:	83 ec 0c             	sub    $0xc,%esp
c0105d79:	68 c4 c4 10 c0       	push   $0xc010c4c4
c0105d7e:	e8 c5 a5 ff ff       	call   c0100348 <cprintf>
c0105d83:	83 c4 10             	add    $0x10,%esp
}
c0105d86:	90                   	nop
c0105d87:	c9                   	leave  
c0105d88:	c3                   	ret    

c0105d89 <check_pgdir>:

static void
check_pgdir(void) {
c0105d89:	55                   	push   %ebp
c0105d8a:	89 e5                	mov    %esp,%ebp
c0105d8c:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105d8f:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0105d94:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0105d99:	76 19                	jbe    c0105db4 <check_pgdir+0x2b>
c0105d9b:	68 e3 c4 10 c0       	push   $0xc010c4e3
c0105da0:	68 0d c4 10 c0       	push   $0xc010c40d
c0105da5:	68 6f 02 00 00       	push   $0x26f
c0105daa:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105daf:	e8 d2 af ff ff       	call   c0100d86 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105db4:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105db9:	85 c0                	test   %eax,%eax
c0105dbb:	74 0e                	je     c0105dcb <check_pgdir+0x42>
c0105dbd:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105dc2:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105dc7:	85 c0                	test   %eax,%eax
c0105dc9:	74 19                	je     c0105de4 <check_pgdir+0x5b>
c0105dcb:	68 00 c5 10 c0       	push   $0xc010c500
c0105dd0:	68 0d c4 10 c0       	push   $0xc010c40d
c0105dd5:	68 70 02 00 00       	push   $0x270
c0105dda:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105ddf:	e8 a2 af ff ff       	call   c0100d86 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105de4:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105de9:	83 ec 04             	sub    $0x4,%esp
c0105dec:	6a 00                	push   $0x0
c0105dee:	6a 00                	push   $0x0
c0105df0:	50                   	push   %eax
c0105df1:	e8 1f f9 ff ff       	call   c0105715 <get_page>
c0105df6:	83 c4 10             	add    $0x10,%esp
c0105df9:	85 c0                	test   %eax,%eax
c0105dfb:	74 19                	je     c0105e16 <check_pgdir+0x8d>
c0105dfd:	68 38 c5 10 c0       	push   $0xc010c538
c0105e02:	68 0d c4 10 c0       	push   $0xc010c40d
c0105e07:	68 71 02 00 00       	push   $0x271
c0105e0c:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105e11:	e8 70 af ff ff       	call   c0100d86 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105e16:	83 ec 0c             	sub    $0xc,%esp
c0105e19:	6a 01                	push   $0x1
c0105e1b:	e8 83 f1 ff ff       	call   c0104fa3 <alloc_pages>
c0105e20:	83 c4 10             	add    $0x10,%esp
c0105e23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105e26:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105e2b:	6a 00                	push   $0x0
c0105e2d:	6a 00                	push   $0x0
c0105e2f:	ff 75 f4             	pushl  -0xc(%ebp)
c0105e32:	50                   	push   %eax
c0105e33:	e8 73 fd ff ff       	call   c0105bab <page_insert>
c0105e38:	83 c4 10             	add    $0x10,%esp
c0105e3b:	85 c0                	test   %eax,%eax
c0105e3d:	74 19                	je     c0105e58 <check_pgdir+0xcf>
c0105e3f:	68 60 c5 10 c0       	push   $0xc010c560
c0105e44:	68 0d c4 10 c0       	push   $0xc010c40d
c0105e49:	68 75 02 00 00       	push   $0x275
c0105e4e:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105e53:	e8 2e af ff ff       	call   c0100d86 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0105e58:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105e5d:	83 ec 04             	sub    $0x4,%esp
c0105e60:	6a 00                	push   $0x0
c0105e62:	6a 00                	push   $0x0
c0105e64:	50                   	push   %eax
c0105e65:	e8 88 f7 ff ff       	call   c01055f2 <get_pte>
c0105e6a:	83 c4 10             	add    $0x10,%esp
c0105e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e74:	75 19                	jne    c0105e8f <check_pgdir+0x106>
c0105e76:	68 8c c5 10 c0       	push   $0xc010c58c
c0105e7b:	68 0d c4 10 c0       	push   $0xc010c40d
c0105e80:	68 78 02 00 00       	push   $0x278
c0105e85:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105e8a:	e8 f7 ae ff ff       	call   c0100d86 <__panic>
    assert(pte2page(*ptep) == p1);
c0105e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e92:	8b 00                	mov    (%eax),%eax
c0105e94:	83 ec 0c             	sub    $0xc,%esp
c0105e97:	50                   	push   %eax
c0105e98:	e8 a1 ee ff ff       	call   c0104d3e <pte2page>
c0105e9d:	83 c4 10             	add    $0x10,%esp
c0105ea0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105ea3:	74 19                	je     c0105ebe <check_pgdir+0x135>
c0105ea5:	68 b9 c5 10 c0       	push   $0xc010c5b9
c0105eaa:	68 0d c4 10 c0       	push   $0xc010c40d
c0105eaf:	68 79 02 00 00       	push   $0x279
c0105eb4:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105eb9:	e8 c8 ae ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p1) == 1);
c0105ebe:	83 ec 0c             	sub    $0xc,%esp
c0105ec1:	ff 75 f4             	pushl  -0xc(%ebp)
c0105ec4:	e8 cb ee ff ff       	call   c0104d94 <page_ref>
c0105ec9:	83 c4 10             	add    $0x10,%esp
c0105ecc:	83 f8 01             	cmp    $0x1,%eax
c0105ecf:	74 19                	je     c0105eea <check_pgdir+0x161>
c0105ed1:	68 cf c5 10 c0       	push   $0xc010c5cf
c0105ed6:	68 0d c4 10 c0       	push   $0xc010c40d
c0105edb:	68 7a 02 00 00       	push   $0x27a
c0105ee0:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105ee5:	e8 9c ae ff ff       	call   c0100d86 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105eea:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105eef:	8b 00                	mov    (%eax),%eax
c0105ef1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105ef6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ef9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105efc:	c1 e8 0c             	shr    $0xc,%eax
c0105eff:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105f02:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0105f07:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105f0a:	72 17                	jb     c0105f23 <check_pgdir+0x19a>
c0105f0c:	ff 75 ec             	pushl  -0x14(%ebp)
c0105f0f:	68 20 c3 10 c0       	push   $0xc010c320
c0105f14:	68 7c 02 00 00       	push   $0x27c
c0105f19:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105f1e:	e8 63 ae ff ff       	call   c0100d86 <__panic>
c0105f23:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f26:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105f2b:	83 c0 04             	add    $0x4,%eax
c0105f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0105f31:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105f36:	83 ec 04             	sub    $0x4,%esp
c0105f39:	6a 00                	push   $0x0
c0105f3b:	68 00 10 00 00       	push   $0x1000
c0105f40:	50                   	push   %eax
c0105f41:	e8 ac f6 ff ff       	call   c01055f2 <get_pte>
c0105f46:	83 c4 10             	add    $0x10,%esp
c0105f49:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105f4c:	74 19                	je     c0105f67 <check_pgdir+0x1de>
c0105f4e:	68 e4 c5 10 c0       	push   $0xc010c5e4
c0105f53:	68 0d c4 10 c0       	push   $0xc010c40d
c0105f58:	68 7d 02 00 00       	push   $0x27d
c0105f5d:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105f62:	e8 1f ae ff ff       	call   c0100d86 <__panic>

    p2 = alloc_page();
c0105f67:	83 ec 0c             	sub    $0xc,%esp
c0105f6a:	6a 01                	push   $0x1
c0105f6c:	e8 32 f0 ff ff       	call   c0104fa3 <alloc_pages>
c0105f71:	83 c4 10             	add    $0x10,%esp
c0105f74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105f77:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105f7c:	6a 06                	push   $0x6
c0105f7e:	68 00 10 00 00       	push   $0x1000
c0105f83:	ff 75 e4             	pushl  -0x1c(%ebp)
c0105f86:	50                   	push   %eax
c0105f87:	e8 1f fc ff ff       	call   c0105bab <page_insert>
c0105f8c:	83 c4 10             	add    $0x10,%esp
c0105f8f:	85 c0                	test   %eax,%eax
c0105f91:	74 19                	je     c0105fac <check_pgdir+0x223>
c0105f93:	68 0c c6 10 c0       	push   $0xc010c60c
c0105f98:	68 0d c4 10 c0       	push   $0xc010c40d
c0105f9d:	68 80 02 00 00       	push   $0x280
c0105fa2:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105fa7:	e8 da ad ff ff       	call   c0100d86 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105fac:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105fb1:	83 ec 04             	sub    $0x4,%esp
c0105fb4:	6a 00                	push   $0x0
c0105fb6:	68 00 10 00 00       	push   $0x1000
c0105fbb:	50                   	push   %eax
c0105fbc:	e8 31 f6 ff ff       	call   c01055f2 <get_pte>
c0105fc1:	83 c4 10             	add    $0x10,%esp
c0105fc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105fc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105fcb:	75 19                	jne    c0105fe6 <check_pgdir+0x25d>
c0105fcd:	68 44 c6 10 c0       	push   $0xc010c644
c0105fd2:	68 0d c4 10 c0       	push   $0xc010c40d
c0105fd7:	68 81 02 00 00       	push   $0x281
c0105fdc:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0105fe1:	e8 a0 ad ff ff       	call   c0100d86 <__panic>
    assert(*ptep & PTE_U);
c0105fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fe9:	8b 00                	mov    (%eax),%eax
c0105feb:	83 e0 04             	and    $0x4,%eax
c0105fee:	85 c0                	test   %eax,%eax
c0105ff0:	75 19                	jne    c010600b <check_pgdir+0x282>
c0105ff2:	68 74 c6 10 c0       	push   $0xc010c674
c0105ff7:	68 0d c4 10 c0       	push   $0xc010c40d
c0105ffc:	68 82 02 00 00       	push   $0x282
c0106001:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106006:	e8 7b ad ff ff       	call   c0100d86 <__panic>
    assert(*ptep & PTE_W);
c010600b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010600e:	8b 00                	mov    (%eax),%eax
c0106010:	83 e0 02             	and    $0x2,%eax
c0106013:	85 c0                	test   %eax,%eax
c0106015:	75 19                	jne    c0106030 <check_pgdir+0x2a7>
c0106017:	68 82 c6 10 c0       	push   $0xc010c682
c010601c:	68 0d c4 10 c0       	push   $0xc010c40d
c0106021:	68 83 02 00 00       	push   $0x283
c0106026:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010602b:	e8 56 ad ff ff       	call   c0100d86 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0106030:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106035:	8b 00                	mov    (%eax),%eax
c0106037:	83 e0 04             	and    $0x4,%eax
c010603a:	85 c0                	test   %eax,%eax
c010603c:	75 19                	jne    c0106057 <check_pgdir+0x2ce>
c010603e:	68 90 c6 10 c0       	push   $0xc010c690
c0106043:	68 0d c4 10 c0       	push   $0xc010c40d
c0106048:	68 84 02 00 00       	push   $0x284
c010604d:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106052:	e8 2f ad ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p2) == 1);
c0106057:	83 ec 0c             	sub    $0xc,%esp
c010605a:	ff 75 e4             	pushl  -0x1c(%ebp)
c010605d:	e8 32 ed ff ff       	call   c0104d94 <page_ref>
c0106062:	83 c4 10             	add    $0x10,%esp
c0106065:	83 f8 01             	cmp    $0x1,%eax
c0106068:	74 19                	je     c0106083 <check_pgdir+0x2fa>
c010606a:	68 a6 c6 10 c0       	push   $0xc010c6a6
c010606f:	68 0d c4 10 c0       	push   $0xc010c40d
c0106074:	68 85 02 00 00       	push   $0x285
c0106079:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010607e:	e8 03 ad ff ff       	call   c0100d86 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0106083:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106088:	6a 00                	push   $0x0
c010608a:	68 00 10 00 00       	push   $0x1000
c010608f:	ff 75 f4             	pushl  -0xc(%ebp)
c0106092:	50                   	push   %eax
c0106093:	e8 13 fb ff ff       	call   c0105bab <page_insert>
c0106098:	83 c4 10             	add    $0x10,%esp
c010609b:	85 c0                	test   %eax,%eax
c010609d:	74 19                	je     c01060b8 <check_pgdir+0x32f>
c010609f:	68 b8 c6 10 c0       	push   $0xc010c6b8
c01060a4:	68 0d c4 10 c0       	push   $0xc010c40d
c01060a9:	68 87 02 00 00       	push   $0x287
c01060ae:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01060b3:	e8 ce ac ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p1) == 2);
c01060b8:	83 ec 0c             	sub    $0xc,%esp
c01060bb:	ff 75 f4             	pushl  -0xc(%ebp)
c01060be:	e8 d1 ec ff ff       	call   c0104d94 <page_ref>
c01060c3:	83 c4 10             	add    $0x10,%esp
c01060c6:	83 f8 02             	cmp    $0x2,%eax
c01060c9:	74 19                	je     c01060e4 <check_pgdir+0x35b>
c01060cb:	68 e4 c6 10 c0       	push   $0xc010c6e4
c01060d0:	68 0d c4 10 c0       	push   $0xc010c40d
c01060d5:	68 88 02 00 00       	push   $0x288
c01060da:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01060df:	e8 a2 ac ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p2) == 0);
c01060e4:	83 ec 0c             	sub    $0xc,%esp
c01060e7:	ff 75 e4             	pushl  -0x1c(%ebp)
c01060ea:	e8 a5 ec ff ff       	call   c0104d94 <page_ref>
c01060ef:	83 c4 10             	add    $0x10,%esp
c01060f2:	85 c0                	test   %eax,%eax
c01060f4:	74 19                	je     c010610f <check_pgdir+0x386>
c01060f6:	68 f6 c6 10 c0       	push   $0xc010c6f6
c01060fb:	68 0d c4 10 c0       	push   $0xc010c40d
c0106100:	68 89 02 00 00       	push   $0x289
c0106105:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010610a:	e8 77 ac ff ff       	call   c0100d86 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010610f:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106114:	83 ec 04             	sub    $0x4,%esp
c0106117:	6a 00                	push   $0x0
c0106119:	68 00 10 00 00       	push   $0x1000
c010611e:	50                   	push   %eax
c010611f:	e8 ce f4 ff ff       	call   c01055f2 <get_pte>
c0106124:	83 c4 10             	add    $0x10,%esp
c0106127:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010612a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010612e:	75 19                	jne    c0106149 <check_pgdir+0x3c0>
c0106130:	68 44 c6 10 c0       	push   $0xc010c644
c0106135:	68 0d c4 10 c0       	push   $0xc010c40d
c010613a:	68 8a 02 00 00       	push   $0x28a
c010613f:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106144:	e8 3d ac ff ff       	call   c0100d86 <__panic>
    assert(pte2page(*ptep) == p1);
c0106149:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010614c:	8b 00                	mov    (%eax),%eax
c010614e:	83 ec 0c             	sub    $0xc,%esp
c0106151:	50                   	push   %eax
c0106152:	e8 e7 eb ff ff       	call   c0104d3e <pte2page>
c0106157:	83 c4 10             	add    $0x10,%esp
c010615a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010615d:	74 19                	je     c0106178 <check_pgdir+0x3ef>
c010615f:	68 b9 c5 10 c0       	push   $0xc010c5b9
c0106164:	68 0d c4 10 c0       	push   $0xc010c40d
c0106169:	68 8b 02 00 00       	push   $0x28b
c010616e:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106173:	e8 0e ac ff ff       	call   c0100d86 <__panic>
    assert((*ptep & PTE_U) == 0);
c0106178:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010617b:	8b 00                	mov    (%eax),%eax
c010617d:	83 e0 04             	and    $0x4,%eax
c0106180:	85 c0                	test   %eax,%eax
c0106182:	74 19                	je     c010619d <check_pgdir+0x414>
c0106184:	68 08 c7 10 c0       	push   $0xc010c708
c0106189:	68 0d c4 10 c0       	push   $0xc010c40d
c010618e:	68 8c 02 00 00       	push   $0x28c
c0106193:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106198:	e8 e9 ab ff ff       	call   c0100d86 <__panic>

    page_remove(boot_pgdir, 0x0);
c010619d:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01061a2:	83 ec 08             	sub    $0x8,%esp
c01061a5:	6a 00                	push   $0x0
c01061a7:	50                   	push   %eax
c01061a8:	e8 c5 f9 ff ff       	call   c0105b72 <page_remove>
c01061ad:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c01061b0:	83 ec 0c             	sub    $0xc,%esp
c01061b3:	ff 75 f4             	pushl  -0xc(%ebp)
c01061b6:	e8 d9 eb ff ff       	call   c0104d94 <page_ref>
c01061bb:	83 c4 10             	add    $0x10,%esp
c01061be:	83 f8 01             	cmp    $0x1,%eax
c01061c1:	74 19                	je     c01061dc <check_pgdir+0x453>
c01061c3:	68 cf c5 10 c0       	push   $0xc010c5cf
c01061c8:	68 0d c4 10 c0       	push   $0xc010c40d
c01061cd:	68 8f 02 00 00       	push   $0x28f
c01061d2:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01061d7:	e8 aa ab ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p2) == 0);
c01061dc:	83 ec 0c             	sub    $0xc,%esp
c01061df:	ff 75 e4             	pushl  -0x1c(%ebp)
c01061e2:	e8 ad eb ff ff       	call   c0104d94 <page_ref>
c01061e7:	83 c4 10             	add    $0x10,%esp
c01061ea:	85 c0                	test   %eax,%eax
c01061ec:	74 19                	je     c0106207 <check_pgdir+0x47e>
c01061ee:	68 f6 c6 10 c0       	push   $0xc010c6f6
c01061f3:	68 0d c4 10 c0       	push   $0xc010c40d
c01061f8:	68 90 02 00 00       	push   $0x290
c01061fd:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106202:	e8 7f ab ff ff       	call   c0100d86 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0106207:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c010620c:	83 ec 08             	sub    $0x8,%esp
c010620f:	68 00 10 00 00       	push   $0x1000
c0106214:	50                   	push   %eax
c0106215:	e8 58 f9 ff ff       	call   c0105b72 <page_remove>
c010621a:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c010621d:	83 ec 0c             	sub    $0xc,%esp
c0106220:	ff 75 f4             	pushl  -0xc(%ebp)
c0106223:	e8 6c eb ff ff       	call   c0104d94 <page_ref>
c0106228:	83 c4 10             	add    $0x10,%esp
c010622b:	85 c0                	test   %eax,%eax
c010622d:	74 19                	je     c0106248 <check_pgdir+0x4bf>
c010622f:	68 1d c7 10 c0       	push   $0xc010c71d
c0106234:	68 0d c4 10 c0       	push   $0xc010c40d
c0106239:	68 93 02 00 00       	push   $0x293
c010623e:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106243:	e8 3e ab ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p2) == 0);
c0106248:	83 ec 0c             	sub    $0xc,%esp
c010624b:	ff 75 e4             	pushl  -0x1c(%ebp)
c010624e:	e8 41 eb ff ff       	call   c0104d94 <page_ref>
c0106253:	83 c4 10             	add    $0x10,%esp
c0106256:	85 c0                	test   %eax,%eax
c0106258:	74 19                	je     c0106273 <check_pgdir+0x4ea>
c010625a:	68 f6 c6 10 c0       	push   $0xc010c6f6
c010625f:	68 0d c4 10 c0       	push   $0xc010c40d
c0106264:	68 94 02 00 00       	push   $0x294
c0106269:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010626e:	e8 13 ab ff ff       	call   c0100d86 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0106273:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106278:	8b 00                	mov    (%eax),%eax
c010627a:	83 ec 0c             	sub    $0xc,%esp
c010627d:	50                   	push   %eax
c010627e:	e8 f5 ea ff ff       	call   c0104d78 <pde2page>
c0106283:	83 c4 10             	add    $0x10,%esp
c0106286:	83 ec 0c             	sub    $0xc,%esp
c0106289:	50                   	push   %eax
c010628a:	e8 05 eb ff ff       	call   c0104d94 <page_ref>
c010628f:	83 c4 10             	add    $0x10,%esp
c0106292:	83 f8 01             	cmp    $0x1,%eax
c0106295:	74 19                	je     c01062b0 <check_pgdir+0x527>
c0106297:	68 30 c7 10 c0       	push   $0xc010c730
c010629c:	68 0d c4 10 c0       	push   $0xc010c40d
c01062a1:	68 96 02 00 00       	push   $0x296
c01062a6:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01062ab:	e8 d6 aa ff ff       	call   c0100d86 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01062b0:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01062b5:	8b 00                	mov    (%eax),%eax
c01062b7:	83 ec 0c             	sub    $0xc,%esp
c01062ba:	50                   	push   %eax
c01062bb:	e8 b8 ea ff ff       	call   c0104d78 <pde2page>
c01062c0:	83 c4 10             	add    $0x10,%esp
c01062c3:	83 ec 08             	sub    $0x8,%esp
c01062c6:	6a 01                	push   $0x1
c01062c8:	50                   	push   %eax
c01062c9:	e8 41 ed ff ff       	call   c010500f <free_pages>
c01062ce:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c01062d1:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01062d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01062dc:	83 ec 0c             	sub    $0xc,%esp
c01062df:	68 57 c7 10 c0       	push   $0xc010c757
c01062e4:	e8 5f a0 ff ff       	call   c0100348 <cprintf>
c01062e9:	83 c4 10             	add    $0x10,%esp
}
c01062ec:	90                   	nop
c01062ed:	c9                   	leave  
c01062ee:	c3                   	ret    

c01062ef <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01062ef:	55                   	push   %ebp
c01062f0:	89 e5                	mov    %esp,%ebp
c01062f2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01062f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01062fc:	e9 a3 00 00 00       	jmp    c01063a4 <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0106301:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106304:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010630a:	c1 e8 0c             	shr    $0xc,%eax
c010630d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106310:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0106315:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0106318:	72 17                	jb     c0106331 <check_boot_pgdir+0x42>
c010631a:	ff 75 e4             	pushl  -0x1c(%ebp)
c010631d:	68 20 c3 10 c0       	push   $0xc010c320
c0106322:	68 a2 02 00 00       	push   $0x2a2
c0106327:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010632c:	e8 55 aa ff ff       	call   c0100d86 <__panic>
c0106331:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106334:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106339:	89 c2                	mov    %eax,%edx
c010633b:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106340:	83 ec 04             	sub    $0x4,%esp
c0106343:	6a 00                	push   $0x0
c0106345:	52                   	push   %edx
c0106346:	50                   	push   %eax
c0106347:	e8 a6 f2 ff ff       	call   c01055f2 <get_pte>
c010634c:	83 c4 10             	add    $0x10,%esp
c010634f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106352:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106356:	75 19                	jne    c0106371 <check_boot_pgdir+0x82>
c0106358:	68 74 c7 10 c0       	push   $0xc010c774
c010635d:	68 0d c4 10 c0       	push   $0xc010c40d
c0106362:	68 a2 02 00 00       	push   $0x2a2
c0106367:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010636c:	e8 15 aa ff ff       	call   c0100d86 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0106371:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106374:	8b 00                	mov    (%eax),%eax
c0106376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010637b:	89 c2                	mov    %eax,%edx
c010637d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106380:	39 c2                	cmp    %eax,%edx
c0106382:	74 19                	je     c010639d <check_boot_pgdir+0xae>
c0106384:	68 b1 c7 10 c0       	push   $0xc010c7b1
c0106389:	68 0d c4 10 c0       	push   $0xc010c40d
c010638e:	68 a3 02 00 00       	push   $0x2a3
c0106393:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106398:	e8 e9 a9 ff ff       	call   c0100d86 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c010639d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01063a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01063a7:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01063ac:	39 c2                	cmp    %eax,%edx
c01063ae:	0f 82 4d ff ff ff    	jb     c0106301 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01063b4:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01063b9:	05 ac 0f 00 00       	add    $0xfac,%eax
c01063be:	8b 00                	mov    (%eax),%eax
c01063c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01063c5:	89 c2                	mov    %eax,%edx
c01063c7:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01063cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01063cf:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01063d6:	77 17                	ja     c01063ef <check_boot_pgdir+0x100>
c01063d8:	ff 75 f0             	pushl  -0x10(%ebp)
c01063db:	68 c4 c3 10 c0       	push   $0xc010c3c4
c01063e0:	68 a6 02 00 00       	push   $0x2a6
c01063e5:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01063ea:	e8 97 a9 ff ff       	call   c0100d86 <__panic>
c01063ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063f2:	05 00 00 00 40       	add    $0x40000000,%eax
c01063f7:	39 d0                	cmp    %edx,%eax
c01063f9:	74 19                	je     c0106414 <check_boot_pgdir+0x125>
c01063fb:	68 c8 c7 10 c0       	push   $0xc010c7c8
c0106400:	68 0d c4 10 c0       	push   $0xc010c40d
c0106405:	68 a6 02 00 00       	push   $0x2a6
c010640a:	68 e8 c3 10 c0       	push   $0xc010c3e8
c010640f:	e8 72 a9 ff ff       	call   c0100d86 <__panic>

    assert(boot_pgdir[0] == 0);
c0106414:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106419:	8b 00                	mov    (%eax),%eax
c010641b:	85 c0                	test   %eax,%eax
c010641d:	74 19                	je     c0106438 <check_boot_pgdir+0x149>
c010641f:	68 fc c7 10 c0       	push   $0xc010c7fc
c0106424:	68 0d c4 10 c0       	push   $0xc010c40d
c0106429:	68 a8 02 00 00       	push   $0x2a8
c010642e:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106433:	e8 4e a9 ff ff       	call   c0100d86 <__panic>

    struct Page *p;
    p = alloc_page();
c0106438:	83 ec 0c             	sub    $0xc,%esp
c010643b:	6a 01                	push   $0x1
c010643d:	e8 61 eb ff ff       	call   c0104fa3 <alloc_pages>
c0106442:	83 c4 10             	add    $0x10,%esp
c0106445:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0106448:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c010644d:	6a 02                	push   $0x2
c010644f:	68 00 01 00 00       	push   $0x100
c0106454:	ff 75 ec             	pushl  -0x14(%ebp)
c0106457:	50                   	push   %eax
c0106458:	e8 4e f7 ff ff       	call   c0105bab <page_insert>
c010645d:	83 c4 10             	add    $0x10,%esp
c0106460:	85 c0                	test   %eax,%eax
c0106462:	74 19                	je     c010647d <check_boot_pgdir+0x18e>
c0106464:	68 10 c8 10 c0       	push   $0xc010c810
c0106469:	68 0d c4 10 c0       	push   $0xc010c40d
c010646e:	68 ac 02 00 00       	push   $0x2ac
c0106473:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106478:	e8 09 a9 ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p) == 1);
c010647d:	83 ec 0c             	sub    $0xc,%esp
c0106480:	ff 75 ec             	pushl  -0x14(%ebp)
c0106483:	e8 0c e9 ff ff       	call   c0104d94 <page_ref>
c0106488:	83 c4 10             	add    $0x10,%esp
c010648b:	83 f8 01             	cmp    $0x1,%eax
c010648e:	74 19                	je     c01064a9 <check_boot_pgdir+0x1ba>
c0106490:	68 3e c8 10 c0       	push   $0xc010c83e
c0106495:	68 0d c4 10 c0       	push   $0xc010c40d
c010649a:	68 ad 02 00 00       	push   $0x2ad
c010649f:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01064a4:	e8 dd a8 ff ff       	call   c0100d86 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01064a9:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01064ae:	6a 02                	push   $0x2
c01064b0:	68 00 11 00 00       	push   $0x1100
c01064b5:	ff 75 ec             	pushl  -0x14(%ebp)
c01064b8:	50                   	push   %eax
c01064b9:	e8 ed f6 ff ff       	call   c0105bab <page_insert>
c01064be:	83 c4 10             	add    $0x10,%esp
c01064c1:	85 c0                	test   %eax,%eax
c01064c3:	74 19                	je     c01064de <check_boot_pgdir+0x1ef>
c01064c5:	68 50 c8 10 c0       	push   $0xc010c850
c01064ca:	68 0d c4 10 c0       	push   $0xc010c40d
c01064cf:	68 ae 02 00 00       	push   $0x2ae
c01064d4:	68 e8 c3 10 c0       	push   $0xc010c3e8
c01064d9:	e8 a8 a8 ff ff       	call   c0100d86 <__panic>
    assert(page_ref(p) == 2);
c01064de:	83 ec 0c             	sub    $0xc,%esp
c01064e1:	ff 75 ec             	pushl  -0x14(%ebp)
c01064e4:	e8 ab e8 ff ff       	call   c0104d94 <page_ref>
c01064e9:	83 c4 10             	add    $0x10,%esp
c01064ec:	83 f8 02             	cmp    $0x2,%eax
c01064ef:	74 19                	je     c010650a <check_boot_pgdir+0x21b>
c01064f1:	68 87 c8 10 c0       	push   $0xc010c887
c01064f6:	68 0d c4 10 c0       	push   $0xc010c40d
c01064fb:	68 af 02 00 00       	push   $0x2af
c0106500:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106505:	e8 7c a8 ff ff       	call   c0100d86 <__panic>

    const char *str = "ucore: Hello world!!";
c010650a:	c7 45 e8 98 c8 10 c0 	movl   $0xc010c898,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0106511:	83 ec 08             	sub    $0x8,%esp
c0106514:	ff 75 e8             	pushl  -0x18(%ebp)
c0106517:	68 00 01 00 00       	push   $0x100
c010651c:	e8 ec 4a 00 00       	call   c010b00d <strcpy>
c0106521:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0106524:	83 ec 08             	sub    $0x8,%esp
c0106527:	68 00 11 00 00       	push   $0x1100
c010652c:	68 00 01 00 00       	push   $0x100
c0106531:	e8 50 4b 00 00       	call   c010b086 <strcmp>
c0106536:	83 c4 10             	add    $0x10,%esp
c0106539:	85 c0                	test   %eax,%eax
c010653b:	74 19                	je     c0106556 <check_boot_pgdir+0x267>
c010653d:	68 b0 c8 10 c0       	push   $0xc010c8b0
c0106542:	68 0d c4 10 c0       	push   $0xc010c40d
c0106547:	68 b3 02 00 00       	push   $0x2b3
c010654c:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106551:	e8 30 a8 ff ff       	call   c0100d86 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106556:	83 ec 0c             	sub    $0xc,%esp
c0106559:	ff 75 ec             	pushl  -0x14(%ebp)
c010655c:	e8 98 e7 ff ff       	call   c0104cf9 <page2kva>
c0106561:	83 c4 10             	add    $0x10,%esp
c0106564:	05 00 01 00 00       	add    $0x100,%eax
c0106569:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010656c:	83 ec 0c             	sub    $0xc,%esp
c010656f:	68 00 01 00 00       	push   $0x100
c0106574:	e8 3c 4a 00 00       	call   c010afb5 <strlen>
c0106579:	83 c4 10             	add    $0x10,%esp
c010657c:	85 c0                	test   %eax,%eax
c010657e:	74 19                	je     c0106599 <check_boot_pgdir+0x2aa>
c0106580:	68 e8 c8 10 c0       	push   $0xc010c8e8
c0106585:	68 0d c4 10 c0       	push   $0xc010c40d
c010658a:	68 b6 02 00 00       	push   $0x2b6
c010658f:	68 e8 c3 10 c0       	push   $0xc010c3e8
c0106594:	e8 ed a7 ff ff       	call   c0100d86 <__panic>

    free_page(p);
c0106599:	83 ec 08             	sub    $0x8,%esp
c010659c:	6a 01                	push   $0x1
c010659e:	ff 75 ec             	pushl  -0x14(%ebp)
c01065a1:	e8 69 ea ff ff       	call   c010500f <free_pages>
c01065a6:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c01065a9:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01065ae:	8b 00                	mov    (%eax),%eax
c01065b0:	83 ec 0c             	sub    $0xc,%esp
c01065b3:	50                   	push   %eax
c01065b4:	e8 bf e7 ff ff       	call   c0104d78 <pde2page>
c01065b9:	83 c4 10             	add    $0x10,%esp
c01065bc:	83 ec 08             	sub    $0x8,%esp
c01065bf:	6a 01                	push   $0x1
c01065c1:	50                   	push   %eax
c01065c2:	e8 48 ea ff ff       	call   c010500f <free_pages>
c01065c7:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c01065ca:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01065cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01065d5:	83 ec 0c             	sub    $0xc,%esp
c01065d8:	68 0c c9 10 c0       	push   $0xc010c90c
c01065dd:	e8 66 9d ff ff       	call   c0100348 <cprintf>
c01065e2:	83 c4 10             	add    $0x10,%esp
}
c01065e5:	90                   	nop
c01065e6:	c9                   	leave  
c01065e7:	c3                   	ret    

c01065e8 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01065e8:	55                   	push   %ebp
c01065e9:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01065eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01065ee:	83 e0 04             	and    $0x4,%eax
c01065f1:	85 c0                	test   %eax,%eax
c01065f3:	74 07                	je     c01065fc <perm2str+0x14>
c01065f5:	b8 75 00 00 00       	mov    $0x75,%eax
c01065fa:	eb 05                	jmp    c0106601 <perm2str+0x19>
c01065fc:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106601:	a2 28 40 1a c0       	mov    %al,0xc01a4028
    str[1] = 'r';
c0106606:	c6 05 29 40 1a c0 72 	movb   $0x72,0xc01a4029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010660d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106610:	83 e0 02             	and    $0x2,%eax
c0106613:	85 c0                	test   %eax,%eax
c0106615:	74 07                	je     c010661e <perm2str+0x36>
c0106617:	b8 77 00 00 00       	mov    $0x77,%eax
c010661c:	eb 05                	jmp    c0106623 <perm2str+0x3b>
c010661e:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106623:	a2 2a 40 1a c0       	mov    %al,0xc01a402a
    str[3] = '\0';
c0106628:	c6 05 2b 40 1a c0 00 	movb   $0x0,0xc01a402b
    return str;
c010662f:	b8 28 40 1a c0       	mov    $0xc01a4028,%eax
}
c0106634:	5d                   	pop    %ebp
c0106635:	c3                   	ret    

c0106636 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106636:	55                   	push   %ebp
c0106637:	89 e5                	mov    %esp,%ebp
c0106639:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010663c:	8b 45 10             	mov    0x10(%ebp),%eax
c010663f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106642:	72 0e                	jb     c0106652 <get_pgtable_items+0x1c>
        return 0;
c0106644:	b8 00 00 00 00       	mov    $0x0,%eax
c0106649:	e9 9a 00 00 00       	jmp    c01066e8 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start++;
c010664e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0106652:	8b 45 10             	mov    0x10(%ebp),%eax
c0106655:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106658:	73 18                	jae    c0106672 <get_pgtable_items+0x3c>
c010665a:	8b 45 10             	mov    0x10(%ebp),%eax
c010665d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106664:	8b 45 14             	mov    0x14(%ebp),%eax
c0106667:	01 d0                	add    %edx,%eax
c0106669:	8b 00                	mov    (%eax),%eax
c010666b:	83 e0 01             	and    $0x1,%eax
c010666e:	85 c0                	test   %eax,%eax
c0106670:	74 dc                	je     c010664e <get_pgtable_items+0x18>
    }
    if (start < right) {
c0106672:	8b 45 10             	mov    0x10(%ebp),%eax
c0106675:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106678:	73 69                	jae    c01066e3 <get_pgtable_items+0xad>
        if (left_store != NULL) {
c010667a:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010667e:	74 08                	je     c0106688 <get_pgtable_items+0x52>
            *left_store = start;
c0106680:	8b 45 18             	mov    0x18(%ebp),%eax
c0106683:	8b 55 10             	mov    0x10(%ebp),%edx
c0106686:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start++] & PTE_USER);
c0106688:	8b 45 10             	mov    0x10(%ebp),%eax
c010668b:	8d 50 01             	lea    0x1(%eax),%edx
c010668e:	89 55 10             	mov    %edx,0x10(%ebp)
c0106691:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106698:	8b 45 14             	mov    0x14(%ebp),%eax
c010669b:	01 d0                	add    %edx,%eax
c010669d:	8b 00                	mov    (%eax),%eax
c010669f:	83 e0 07             	and    $0x7,%eax
c01066a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01066a5:	eb 04                	jmp    c01066ab <get_pgtable_items+0x75>
            start++;
c01066a7:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01066ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01066ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01066b1:	73 1d                	jae    c01066d0 <get_pgtable_items+0x9a>
c01066b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01066b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01066bd:	8b 45 14             	mov    0x14(%ebp),%eax
c01066c0:	01 d0                	add    %edx,%eax
c01066c2:	8b 00                	mov    (%eax),%eax
c01066c4:	83 e0 07             	and    $0x7,%eax
c01066c7:	89 c2                	mov    %eax,%edx
c01066c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01066cc:	39 c2                	cmp    %eax,%edx
c01066ce:	74 d7                	je     c01066a7 <get_pgtable_items+0x71>
        }
        if (right_store != NULL) {
c01066d0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01066d4:	74 08                	je     c01066de <get_pgtable_items+0xa8>
            *right_store = start;
c01066d6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01066d9:	8b 55 10             	mov    0x10(%ebp),%edx
c01066dc:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01066de:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01066e1:	eb 05                	jmp    c01066e8 <get_pgtable_items+0xb2>
    }
    return 0;
c01066e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01066e8:	c9                   	leave  
c01066e9:	c3                   	ret    

c01066ea <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01066ea:	55                   	push   %ebp
c01066eb:	89 e5                	mov    %esp,%ebp
c01066ed:	57                   	push   %edi
c01066ee:	56                   	push   %esi
c01066ef:	53                   	push   %ebx
c01066f0:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01066f3:	83 ec 0c             	sub    $0xc,%esp
c01066f6:	68 2c c9 10 c0       	push   $0xc010c92c
c01066fb:	e8 48 9c ff ff       	call   c0100348 <cprintf>
c0106700:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0106703:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010670a:	e9 d9 00 00 00       	jmp    c01067e8 <print_pgdir+0xfe>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010670f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106712:	83 ec 0c             	sub    $0xc,%esp
c0106715:	50                   	push   %eax
c0106716:	e8 cd fe ff ff       	call   c01065e8 <perm2str>
c010671b:	83 c4 10             	add    $0x10,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010671e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106721:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106724:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106726:	89 d6                	mov    %edx,%esi
c0106728:	c1 e6 16             	shl    $0x16,%esi
c010672b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010672e:	89 d3                	mov    %edx,%ebx
c0106730:	c1 e3 16             	shl    $0x16,%ebx
c0106733:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106736:	89 d1                	mov    %edx,%ecx
c0106738:	c1 e1 16             	shl    $0x16,%ecx
c010673b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010673e:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0106741:	29 fa                	sub    %edi,%edx
c0106743:	83 ec 08             	sub    $0x8,%esp
c0106746:	50                   	push   %eax
c0106747:	56                   	push   %esi
c0106748:	53                   	push   %ebx
c0106749:	51                   	push   %ecx
c010674a:	52                   	push   %edx
c010674b:	68 5d c9 10 c0       	push   $0xc010c95d
c0106750:	e8 f3 9b ff ff       	call   c0100348 <cprintf>
c0106755:	83 c4 20             	add    $0x20,%esp
        size_t l, r = left * NPTEENTRY;
c0106758:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010675b:	c1 e0 0a             	shl    $0xa,%eax
c010675e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106761:	eb 49                	jmp    c01067ac <print_pgdir+0xc2>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106763:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106766:	83 ec 0c             	sub    $0xc,%esp
c0106769:	50                   	push   %eax
c010676a:	e8 79 fe ff ff       	call   c01065e8 <perm2str>
c010676f:	83 c4 10             	add    $0x10,%esp
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106772:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106775:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0106778:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010677a:	89 d6                	mov    %edx,%esi
c010677c:	c1 e6 0c             	shl    $0xc,%esi
c010677f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106782:	89 d3                	mov    %edx,%ebx
c0106784:	c1 e3 0c             	shl    $0xc,%ebx
c0106787:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010678a:	89 d1                	mov    %edx,%ecx
c010678c:	c1 e1 0c             	shl    $0xc,%ecx
c010678f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106792:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0106795:	29 fa                	sub    %edi,%edx
c0106797:	83 ec 08             	sub    $0x8,%esp
c010679a:	50                   	push   %eax
c010679b:	56                   	push   %esi
c010679c:	53                   	push   %ebx
c010679d:	51                   	push   %ecx
c010679e:	52                   	push   %edx
c010679f:	68 7c c9 10 c0       	push   $0xc010c97c
c01067a4:	e8 9f 9b ff ff       	call   c0100348 <cprintf>
c01067a9:	83 c4 20             	add    $0x20,%esp
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01067ac:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01067b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01067b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01067b7:	89 d3                	mov    %edx,%ebx
c01067b9:	c1 e3 0a             	shl    $0xa,%ebx
c01067bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01067bf:	89 d1                	mov    %edx,%ecx
c01067c1:	c1 e1 0a             	shl    $0xa,%ecx
c01067c4:	83 ec 08             	sub    $0x8,%esp
c01067c7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01067ca:	52                   	push   %edx
c01067cb:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01067ce:	52                   	push   %edx
c01067cf:	56                   	push   %esi
c01067d0:	50                   	push   %eax
c01067d1:	53                   	push   %ebx
c01067d2:	51                   	push   %ecx
c01067d3:	e8 5e fe ff ff       	call   c0106636 <get_pgtable_items>
c01067d8:	83 c4 20             	add    $0x20,%esp
c01067db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01067de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01067e2:	0f 85 7b ff ff ff    	jne    c0106763 <print_pgdir+0x79>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01067e8:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01067ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01067f0:	83 ec 08             	sub    $0x8,%esp
c01067f3:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01067f6:	52                   	push   %edx
c01067f7:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01067fa:	52                   	push   %edx
c01067fb:	51                   	push   %ecx
c01067fc:	50                   	push   %eax
c01067fd:	68 00 04 00 00       	push   $0x400
c0106802:	6a 00                	push   $0x0
c0106804:	e8 2d fe ff ff       	call   c0106636 <get_pgtable_items>
c0106809:	83 c4 20             	add    $0x20,%esp
c010680c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010680f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106813:	0f 85 f6 fe ff ff    	jne    c010670f <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106819:	83 ec 0c             	sub    $0xc,%esp
c010681c:	68 a0 c9 10 c0       	push   $0xc010c9a0
c0106821:	e8 22 9b ff ff       	call   c0100348 <cprintf>
c0106826:	83 c4 10             	add    $0x10,%esp
}
c0106829:	90                   	nop
c010682a:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010682d:	5b                   	pop    %ebx
c010682e:	5e                   	pop    %esi
c010682f:	5f                   	pop    %edi
c0106830:	5d                   	pop    %ebp
c0106831:	c3                   	ret    

c0106832 <pa2page>:
pa2page(uintptr_t pa) {
c0106832:	55                   	push   %ebp
c0106833:	89 e5                	mov    %esp,%ebp
c0106835:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0106838:	8b 45 08             	mov    0x8(%ebp),%eax
c010683b:	c1 e8 0c             	shr    $0xc,%eax
c010683e:	89 c2                	mov    %eax,%edx
c0106840:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0106845:	39 c2                	cmp    %eax,%edx
c0106847:	72 14                	jb     c010685d <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0106849:	83 ec 04             	sub    $0x4,%esp
c010684c:	68 d4 c9 10 c0       	push   $0xc010c9d4
c0106851:	6a 5e                	push   $0x5e
c0106853:	68 f3 c9 10 c0       	push   $0xc010c9f3
c0106858:	e8 29 a5 ff ff       	call   c0100d86 <__panic>
    return &pages[PPN(pa)];
c010685d:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0106863:	8b 45 08             	mov    0x8(%ebp),%eax
c0106866:	c1 e8 0c             	shr    $0xc,%eax
c0106869:	c1 e0 05             	shl    $0x5,%eax
c010686c:	01 d0                	add    %edx,%eax
}
c010686e:	c9                   	leave  
c010686f:	c3                   	ret    

c0106870 <pte2page>:
pte2page(pte_t pte) {
c0106870:	55                   	push   %ebp
c0106871:	89 e5                	mov    %esp,%ebp
c0106873:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0106876:	8b 45 08             	mov    0x8(%ebp),%eax
c0106879:	83 e0 01             	and    $0x1,%eax
c010687c:	85 c0                	test   %eax,%eax
c010687e:	75 14                	jne    c0106894 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0106880:	83 ec 04             	sub    $0x4,%esp
c0106883:	68 04 ca 10 c0       	push   $0xc010ca04
c0106888:	6a 70                	push   $0x70
c010688a:	68 f3 c9 10 c0       	push   $0xc010c9f3
c010688f:	e8 f2 a4 ff ff       	call   c0100d86 <__panic>
    return pa2page(PTE_ADDR(pte));
c0106894:	8b 45 08             	mov    0x8(%ebp),%eax
c0106897:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010689c:	83 ec 0c             	sub    $0xc,%esp
c010689f:	50                   	push   %eax
c01068a0:	e8 8d ff ff ff       	call   c0106832 <pa2page>
c01068a5:	83 c4 10             	add    $0x10,%esp
}
c01068a8:	c9                   	leave  
c01068a9:	c3                   	ret    

c01068aa <pde2page>:
pde2page(pde_t pde) {
c01068aa:	55                   	push   %ebp
c01068ab:	89 e5                	mov    %esp,%ebp
c01068ad:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c01068b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01068b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01068b8:	83 ec 0c             	sub    $0xc,%esp
c01068bb:	50                   	push   %eax
c01068bc:	e8 71 ff ff ff       	call   c0106832 <pa2page>
c01068c1:	83 c4 10             	add    $0x10,%esp
}
c01068c4:	c9                   	leave  
c01068c5:	c3                   	ret    

c01068c6 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01068c6:	55                   	push   %ebp
c01068c7:	89 e5                	mov    %esp,%ebp
c01068c9:	83 ec 18             	sub    $0x18,%esp
     swapfs_init();
c01068cc:	e8 2c 21 00 00       	call   c01089fd <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01068d1:	a1 40 40 1a c0       	mov    0xc01a4040,%eax
c01068d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01068db:	76 0c                	jbe    c01068e9 <swap_init+0x23>
c01068dd:	a1 40 40 1a c0       	mov    0xc01a4040,%eax
c01068e2:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01068e7:	76 17                	jbe    c0106900 <swap_init+0x3a>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01068e9:	a1 40 40 1a c0       	mov    0xc01a4040,%eax
c01068ee:	50                   	push   %eax
c01068ef:	68 25 ca 10 c0       	push   $0xc010ca25
c01068f4:	6a 27                	push   $0x27
c01068f6:	68 40 ca 10 c0       	push   $0xc010ca40
c01068fb:	e8 86 a4 ff ff       	call   c0100d86 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106900:	c7 05 00 41 1a c0 60 	movl   $0xc012fa60,0xc01a4100
c0106907:	fa 12 c0 
     int r = sm->init();
c010690a:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c010690f:	8b 40 04             	mov    0x4(%eax),%eax
c0106912:	ff d0                	call   *%eax
c0106914:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106917:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010691b:	75 27                	jne    c0106944 <swap_init+0x7e>
     {
          swap_init_ok = 1;
c010691d:	c7 05 44 40 1a c0 01 	movl   $0x1,0xc01a4044
c0106924:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106927:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c010692c:	8b 00                	mov    (%eax),%eax
c010692e:	83 ec 08             	sub    $0x8,%esp
c0106931:	50                   	push   %eax
c0106932:	68 4f ca 10 c0       	push   $0xc010ca4f
c0106937:	e8 0c 9a ff ff       	call   c0100348 <cprintf>
c010693c:	83 c4 10             	add    $0x10,%esp
          check_swap();
c010693f:	e8 f7 03 00 00       	call   c0106d3b <check_swap>
     }

     return r;
c0106944:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106947:	c9                   	leave  
c0106948:	c3                   	ret    

c0106949 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106949:	55                   	push   %ebp
c010694a:	89 e5                	mov    %esp,%ebp
c010694c:	83 ec 08             	sub    $0x8,%esp
     return sm->init_mm(mm);
c010694f:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0106954:	8b 40 08             	mov    0x8(%eax),%eax
c0106957:	83 ec 0c             	sub    $0xc,%esp
c010695a:	ff 75 08             	pushl  0x8(%ebp)
c010695d:	ff d0                	call   *%eax
c010695f:	83 c4 10             	add    $0x10,%esp
}
c0106962:	c9                   	leave  
c0106963:	c3                   	ret    

c0106964 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106964:	55                   	push   %ebp
c0106965:	89 e5                	mov    %esp,%ebp
c0106967:	83 ec 08             	sub    $0x8,%esp
     return sm->tick_event(mm);
c010696a:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c010696f:	8b 40 0c             	mov    0xc(%eax),%eax
c0106972:	83 ec 0c             	sub    $0xc,%esp
c0106975:	ff 75 08             	pushl  0x8(%ebp)
c0106978:	ff d0                	call   *%eax
c010697a:	83 c4 10             	add    $0x10,%esp
}
c010697d:	c9                   	leave  
c010697e:	c3                   	ret    

c010697f <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c010697f:	55                   	push   %ebp
c0106980:	89 e5                	mov    %esp,%ebp
c0106982:	83 ec 08             	sub    $0x8,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106985:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c010698a:	8b 40 10             	mov    0x10(%eax),%eax
c010698d:	ff 75 14             	pushl  0x14(%ebp)
c0106990:	ff 75 10             	pushl  0x10(%ebp)
c0106993:	ff 75 0c             	pushl  0xc(%ebp)
c0106996:	ff 75 08             	pushl  0x8(%ebp)
c0106999:	ff d0                	call   *%eax
c010699b:	83 c4 10             	add    $0x10,%esp
}
c010699e:	c9                   	leave  
c010699f:	c3                   	ret    

c01069a0 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01069a0:	55                   	push   %ebp
c01069a1:	89 e5                	mov    %esp,%ebp
c01069a3:	83 ec 08             	sub    $0x8,%esp
     return sm->set_unswappable(mm, addr);
c01069a6:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c01069ab:	8b 40 14             	mov    0x14(%eax),%eax
c01069ae:	83 ec 08             	sub    $0x8,%esp
c01069b1:	ff 75 0c             	pushl  0xc(%ebp)
c01069b4:	ff 75 08             	pushl  0x8(%ebp)
c01069b7:	ff d0                	call   *%eax
c01069b9:	83 c4 10             	add    $0x10,%esp
}
c01069bc:	c9                   	leave  
c01069bd:	c3                   	ret    

c01069be <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01069be:	55                   	push   %ebp
c01069bf:	89 e5                	mov    %esp,%ebp
c01069c1:	83 ec 28             	sub    $0x28,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01069c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01069cb:	e9 2e 01 00 00       	jmp    c0106afe <swap_out+0x140>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01069d0:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c01069d5:	8b 40 18             	mov    0x18(%eax),%eax
c01069d8:	83 ec 04             	sub    $0x4,%esp
c01069db:	ff 75 10             	pushl  0x10(%ebp)
c01069de:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c01069e1:	52                   	push   %edx
c01069e2:	ff 75 08             	pushl  0x8(%ebp)
c01069e5:	ff d0                	call   *%eax
c01069e7:	83 c4 10             	add    $0x10,%esp
c01069ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01069ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01069f1:	74 18                	je     c0106a0b <swap_out+0x4d>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01069f3:	83 ec 08             	sub    $0x8,%esp
c01069f6:	ff 75 f4             	pushl  -0xc(%ebp)
c01069f9:	68 64 ca 10 c0       	push   $0xc010ca64
c01069fe:	e8 45 99 ff ff       	call   c0100348 <cprintf>
c0106a03:	83 c4 10             	add    $0x10,%esp
c0106a06:	e9 ff 00 00 00       	jmp    c0106b0a <swap_out+0x14c>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106a0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a0e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106a11:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106a14:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a17:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a1a:	83 ec 04             	sub    $0x4,%esp
c0106a1d:	6a 00                	push   $0x0
c0106a1f:	ff 75 ec             	pushl  -0x14(%ebp)
c0106a22:	50                   	push   %eax
c0106a23:	e8 ca eb ff ff       	call   c01055f2 <get_pte>
c0106a28:	83 c4 10             	add    $0x10,%esp
c0106a2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106a2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a31:	8b 00                	mov    (%eax),%eax
c0106a33:	83 e0 01             	and    $0x1,%eax
c0106a36:	85 c0                	test   %eax,%eax
c0106a38:	75 16                	jne    c0106a50 <swap_out+0x92>
c0106a3a:	68 91 ca 10 c0       	push   $0xc010ca91
c0106a3f:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106a44:	6a 67                	push   $0x67
c0106a46:	68 40 ca 10 c0       	push   $0xc010ca40
c0106a4b:	e8 36 a3 ff ff       	call   c0100d86 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106a50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106a56:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106a59:	c1 ea 0c             	shr    $0xc,%edx
c0106a5c:	83 c2 01             	add    $0x1,%edx
c0106a5f:	c1 e2 08             	shl    $0x8,%edx
c0106a62:	83 ec 08             	sub    $0x8,%esp
c0106a65:	50                   	push   %eax
c0106a66:	52                   	push   %edx
c0106a67:	e8 2c 20 00 00       	call   c0108a98 <swapfs_write>
c0106a6c:	83 c4 10             	add    $0x10,%esp
c0106a6f:	85 c0                	test   %eax,%eax
c0106a71:	74 2b                	je     c0106a9e <swap_out+0xe0>
                    cprintf("SWAP: failed to save\n");
c0106a73:	83 ec 0c             	sub    $0xc,%esp
c0106a76:	68 bb ca 10 c0       	push   $0xc010cabb
c0106a7b:	e8 c8 98 ff ff       	call   c0100348 <cprintf>
c0106a80:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c0106a83:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0106a88:	8b 40 10             	mov    0x10(%eax),%eax
c0106a8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106a8e:	6a 00                	push   $0x0
c0106a90:	52                   	push   %edx
c0106a91:	ff 75 ec             	pushl  -0x14(%ebp)
c0106a94:	ff 75 08             	pushl  0x8(%ebp)
c0106a97:	ff d0                	call   *%eax
c0106a99:	83 c4 10             	add    $0x10,%esp
c0106a9c:	eb 5c                	jmp    c0106afa <swap_out+0x13c>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106a9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106aa1:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106aa4:	c1 e8 0c             	shr    $0xc,%eax
c0106aa7:	83 c0 01             	add    $0x1,%eax
c0106aaa:	50                   	push   %eax
c0106aab:	ff 75 ec             	pushl  -0x14(%ebp)
c0106aae:	ff 75 f4             	pushl  -0xc(%ebp)
c0106ab1:	68 d4 ca 10 c0       	push   $0xc010cad4
c0106ab6:	e8 8d 98 ff ff       	call   c0100348 <cprintf>
c0106abb:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106abe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ac1:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106ac4:	c1 e8 0c             	shr    $0xc,%eax
c0106ac7:	83 c0 01             	add    $0x1,%eax
c0106aca:	c1 e0 08             	shl    $0x8,%eax
c0106acd:	89 c2                	mov    %eax,%edx
c0106acf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ad2:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ad7:	83 ec 08             	sub    $0x8,%esp
c0106ada:	6a 01                	push   $0x1
c0106adc:	50                   	push   %eax
c0106add:	e8 2d e5 ff ff       	call   c010500f <free_pages>
c0106ae2:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106ae5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ae8:	8b 40 0c             	mov    0xc(%eax),%eax
c0106aeb:	83 ec 08             	sub    $0x8,%esp
c0106aee:	ff 75 ec             	pushl  -0x14(%ebp)
c0106af1:	50                   	push   %eax
c0106af2:	e8 6d f1 ff ff       	call   c0105c64 <tlb_invalidate>
c0106af7:	83 c4 10             	add    $0x10,%esp
     for (i = 0; i != n; ++ i)
c0106afa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b01:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b04:	0f 85 c6 fe ff ff    	jne    c01069d0 <swap_out+0x12>
     }
     return i;
c0106b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106b0d:	c9                   	leave  
c0106b0e:	c3                   	ret    

c0106b0f <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106b0f:	55                   	push   %ebp
c0106b10:	89 e5                	mov    %esp,%ebp
c0106b12:	83 ec 18             	sub    $0x18,%esp
     struct Page *result = alloc_page();
c0106b15:	83 ec 0c             	sub    $0xc,%esp
c0106b18:	6a 01                	push   $0x1
c0106b1a:	e8 84 e4 ff ff       	call   c0104fa3 <alloc_pages>
c0106b1f:	83 c4 10             	add    $0x10,%esp
c0106b22:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106b25:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106b29:	75 16                	jne    c0106b41 <swap_in+0x32>
c0106b2b:	68 14 cb 10 c0       	push   $0xc010cb14
c0106b30:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106b35:	6a 7d                	push   $0x7d
c0106b37:	68 40 ca 10 c0       	push   $0xc010ca40
c0106b3c:	e8 45 a2 ff ff       	call   c0100d86 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b44:	8b 40 0c             	mov    0xc(%eax),%eax
c0106b47:	83 ec 04             	sub    $0x4,%esp
c0106b4a:	6a 00                	push   $0x0
c0106b4c:	ff 75 0c             	pushl  0xc(%ebp)
c0106b4f:	50                   	push   %eax
c0106b50:	e8 9d ea ff ff       	call   c01055f2 <get_pte>
c0106b55:	83 c4 10             	add    $0x10,%esp
c0106b58:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b5e:	8b 00                	mov    (%eax),%eax
c0106b60:	83 ec 08             	sub    $0x8,%esp
c0106b63:	ff 75 f4             	pushl  -0xc(%ebp)
c0106b66:	50                   	push   %eax
c0106b67:	e8 d4 1e 00 00       	call   c0108a40 <swapfs_read>
c0106b6c:	83 c4 10             	add    $0x10,%esp
c0106b6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106b72:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106b76:	74 1f                	je     c0106b97 <swap_in+0x88>
     {
        assert(r!=0);
c0106b78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106b7c:	75 19                	jne    c0106b97 <swap_in+0x88>
c0106b7e:	68 21 cb 10 c0       	push   $0xc010cb21
c0106b83:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106b88:	68 85 00 00 00       	push   $0x85
c0106b8d:	68 40 ca 10 c0       	push   $0xc010ca40
c0106b92:	e8 ef a1 ff ff       	call   c0100d86 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b9a:	8b 00                	mov    (%eax),%eax
c0106b9c:	c1 e8 08             	shr    $0x8,%eax
c0106b9f:	83 ec 04             	sub    $0x4,%esp
c0106ba2:	ff 75 0c             	pushl  0xc(%ebp)
c0106ba5:	50                   	push   %eax
c0106ba6:	68 28 cb 10 c0       	push   $0xc010cb28
c0106bab:	e8 98 97 ff ff       	call   c0100348 <cprintf>
c0106bb0:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c0106bb3:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106bb9:	89 10                	mov    %edx,(%eax)
     return 0;
c0106bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106bc0:	c9                   	leave  
c0106bc1:	c3                   	ret    

c0106bc2 <check_content_set>:



static inline void
check_content_set(void)
{
c0106bc2:	55                   	push   %ebp
c0106bc3:	89 e5                	mov    %esp,%ebp
c0106bc5:	83 ec 08             	sub    $0x8,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106bc8:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106bcd:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106bd0:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106bd5:	83 f8 01             	cmp    $0x1,%eax
c0106bd8:	74 19                	je     c0106bf3 <check_content_set+0x31>
c0106bda:	68 66 cb 10 c0       	push   $0xc010cb66
c0106bdf:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106be4:	68 92 00 00 00       	push   $0x92
c0106be9:	68 40 ca 10 c0       	push   $0xc010ca40
c0106bee:	e8 93 a1 ff ff       	call   c0100d86 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106bf3:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106bf8:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106bfb:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106c00:	83 f8 01             	cmp    $0x1,%eax
c0106c03:	74 19                	je     c0106c1e <check_content_set+0x5c>
c0106c05:	68 66 cb 10 c0       	push   $0xc010cb66
c0106c0a:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106c0f:	68 94 00 00 00       	push   $0x94
c0106c14:	68 40 ca 10 c0       	push   $0xc010ca40
c0106c19:	e8 68 a1 ff ff       	call   c0100d86 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106c1e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106c23:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106c26:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106c2b:	83 f8 02             	cmp    $0x2,%eax
c0106c2e:	74 19                	je     c0106c49 <check_content_set+0x87>
c0106c30:	68 75 cb 10 c0       	push   $0xc010cb75
c0106c35:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106c3a:	68 96 00 00 00       	push   $0x96
c0106c3f:	68 40 ca 10 c0       	push   $0xc010ca40
c0106c44:	e8 3d a1 ff ff       	call   c0100d86 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106c49:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106c4e:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106c51:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106c56:	83 f8 02             	cmp    $0x2,%eax
c0106c59:	74 19                	je     c0106c74 <check_content_set+0xb2>
c0106c5b:	68 75 cb 10 c0       	push   $0xc010cb75
c0106c60:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106c65:	68 98 00 00 00       	push   $0x98
c0106c6a:	68 40 ca 10 c0       	push   $0xc010ca40
c0106c6f:	e8 12 a1 ff ff       	call   c0100d86 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106c74:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106c79:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106c7c:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106c81:	83 f8 03             	cmp    $0x3,%eax
c0106c84:	74 19                	je     c0106c9f <check_content_set+0xdd>
c0106c86:	68 84 cb 10 c0       	push   $0xc010cb84
c0106c8b:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106c90:	68 9a 00 00 00       	push   $0x9a
c0106c95:	68 40 ca 10 c0       	push   $0xc010ca40
c0106c9a:	e8 e7 a0 ff ff       	call   c0100d86 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106c9f:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106ca4:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106ca7:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106cac:	83 f8 03             	cmp    $0x3,%eax
c0106caf:	74 19                	je     c0106cca <check_content_set+0x108>
c0106cb1:	68 84 cb 10 c0       	push   $0xc010cb84
c0106cb6:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106cbb:	68 9c 00 00 00       	push   $0x9c
c0106cc0:	68 40 ca 10 c0       	push   $0xc010ca40
c0106cc5:	e8 bc a0 ff ff       	call   c0100d86 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106cca:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106ccf:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106cd2:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106cd7:	83 f8 04             	cmp    $0x4,%eax
c0106cda:	74 19                	je     c0106cf5 <check_content_set+0x133>
c0106cdc:	68 93 cb 10 c0       	push   $0xc010cb93
c0106ce1:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106ce6:	68 9e 00 00 00       	push   $0x9e
c0106ceb:	68 40 ca 10 c0       	push   $0xc010ca40
c0106cf0:	e8 91 a0 ff ff       	call   c0100d86 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106cf5:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106cfa:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106cfd:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0106d02:	83 f8 04             	cmp    $0x4,%eax
c0106d05:	74 19                	je     c0106d20 <check_content_set+0x15e>
c0106d07:	68 93 cb 10 c0       	push   $0xc010cb93
c0106d0c:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106d11:	68 a0 00 00 00       	push   $0xa0
c0106d16:	68 40 ca 10 c0       	push   $0xc010ca40
c0106d1b:	e8 66 a0 ff ff       	call   c0100d86 <__panic>
}
c0106d20:	90                   	nop
c0106d21:	c9                   	leave  
c0106d22:	c3                   	ret    

c0106d23 <check_content_access>:

static inline int
check_content_access(void)
{
c0106d23:	55                   	push   %ebp
c0106d24:	89 e5                	mov    %esp,%ebp
c0106d26:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106d29:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0106d2e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106d31:	ff d0                	call   *%eax
c0106d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106d39:	c9                   	leave  
c0106d3a:	c3                   	ret    

c0106d3b <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106d3b:	55                   	push   %ebp
c0106d3c:	89 e5                	mov    %esp,%ebp
c0106d3e:	83 ec 68             	sub    $0x68,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106d41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106d48:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106d4f:	c7 45 e8 84 3f 1a c0 	movl   $0xc01a3f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106d56:	eb 60                	jmp    c0106db8 <check_swap+0x7d>
        struct Page *p = le2page(le, page_link);
c0106d58:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d5b:	83 e8 0c             	sub    $0xc,%eax
c0106d5e:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106d61:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106d64:	83 c0 04             	add    $0x4,%eax
c0106d67:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106d6e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106d71:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106d74:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106d77:	0f a3 10             	bt     %edx,(%eax)
c0106d7a:	19 c0                	sbb    %eax,%eax
c0106d7c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106d7f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106d83:	0f 95 c0             	setne  %al
c0106d86:	0f b6 c0             	movzbl %al,%eax
c0106d89:	85 c0                	test   %eax,%eax
c0106d8b:	75 19                	jne    c0106da6 <check_swap+0x6b>
c0106d8d:	68 a2 cb 10 c0       	push   $0xc010cba2
c0106d92:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106d97:	68 bb 00 00 00       	push   $0xbb
c0106d9c:	68 40 ca 10 c0       	push   $0xc010ca40
c0106da1:	e8 e0 9f ff ff       	call   c0100d86 <__panic>
        count ++, total += p->property;
c0106da6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106daa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106dad:	8b 50 08             	mov    0x8(%eax),%edx
c0106db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106db3:	01 d0                	add    %edx,%eax
c0106db5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106db8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106dbb:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106dbe:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106dc1:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106dc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106dc7:	81 7d e8 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x18(%ebp)
c0106dce:	75 88                	jne    c0106d58 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0106dd0:	e8 6f e2 ff ff       	call   c0105044 <nr_free_pages>
c0106dd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106dd8:	39 d0                	cmp    %edx,%eax
c0106dda:	74 19                	je     c0106df5 <check_swap+0xba>
c0106ddc:	68 b2 cb 10 c0       	push   $0xc010cbb2
c0106de1:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106de6:	68 be 00 00 00       	push   $0xbe
c0106deb:	68 40 ca 10 c0       	push   $0xc010ca40
c0106df0:	e8 91 9f ff ff       	call   c0100d86 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106df5:	83 ec 04             	sub    $0x4,%esp
c0106df8:	ff 75 f0             	pushl  -0x10(%ebp)
c0106dfb:	ff 75 f4             	pushl  -0xc(%ebp)
c0106dfe:	68 cc cb 10 c0       	push   $0xc010cbcc
c0106e03:	e8 40 95 ff ff       	call   c0100348 <cprintf>
c0106e08:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106e0b:	e8 3b 0b 00 00       	call   c010794b <mm_create>
c0106e10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106e13:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e17:	75 19                	jne    c0106e32 <check_swap+0xf7>
c0106e19:	68 f2 cb 10 c0       	push   $0xc010cbf2
c0106e1e:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106e23:	68 c3 00 00 00       	push   $0xc3
c0106e28:	68 40 ca 10 c0       	push   $0xc010ca40
c0106e2d:	e8 54 9f ff ff       	call   c0100d86 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106e32:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0106e37:	85 c0                	test   %eax,%eax
c0106e39:	74 19                	je     c0106e54 <check_swap+0x119>
c0106e3b:	68 fd cb 10 c0       	push   $0xc010cbfd
c0106e40:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106e45:	68 c6 00 00 00       	push   $0xc6
c0106e4a:	68 40 ca 10 c0       	push   $0xc010ca40
c0106e4f:	e8 32 9f ff ff       	call   c0100d86 <__panic>

     check_mm_struct = mm;
c0106e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e57:	a3 0c 41 1a c0       	mov    %eax,0xc01a410c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106e5c:	8b 15 00 fa 12 c0    	mov    0xc012fa00,%edx
c0106e62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e65:	89 50 0c             	mov    %edx,0xc(%eax)
c0106e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e6b:	8b 40 0c             	mov    0xc(%eax),%eax
c0106e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106e71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e74:	8b 00                	mov    (%eax),%eax
c0106e76:	85 c0                	test   %eax,%eax
c0106e78:	74 19                	je     c0106e93 <check_swap+0x158>
c0106e7a:	68 15 cc 10 c0       	push   $0xc010cc15
c0106e7f:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106e84:	68 cb 00 00 00       	push   $0xcb
c0106e89:	68 40 ca 10 c0       	push   $0xc010ca40
c0106e8e:	e8 f3 9e ff ff       	call   c0100d86 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106e93:	83 ec 04             	sub    $0x4,%esp
c0106e96:	6a 03                	push   $0x3
c0106e98:	68 00 60 00 00       	push   $0x6000
c0106e9d:	68 00 10 00 00       	push   $0x1000
c0106ea2:	e8 43 0b 00 00       	call   c01079ea <vma_create>
c0106ea7:	83 c4 10             	add    $0x10,%esp
c0106eaa:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106ead:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106eb1:	75 19                	jne    c0106ecc <check_swap+0x191>
c0106eb3:	68 23 cc 10 c0       	push   $0xc010cc23
c0106eb8:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106ebd:	68 ce 00 00 00       	push   $0xce
c0106ec2:	68 40 ca 10 c0       	push   $0xc010ca40
c0106ec7:	e8 ba 9e ff ff       	call   c0100d86 <__panic>

     insert_vma_struct(mm, vma);
c0106ecc:	83 ec 08             	sub    $0x8,%esp
c0106ecf:	ff 75 dc             	pushl  -0x24(%ebp)
c0106ed2:	ff 75 e4             	pushl  -0x1c(%ebp)
c0106ed5:	e8 78 0c 00 00       	call   c0107b52 <insert_vma_struct>
c0106eda:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106edd:	83 ec 0c             	sub    $0xc,%esp
c0106ee0:	68 30 cc 10 c0       	push   $0xc010cc30
c0106ee5:	e8 5e 94 ff ff       	call   c0100348 <cprintf>
c0106eea:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c0106eed:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ef7:	8b 40 0c             	mov    0xc(%eax),%eax
c0106efa:	83 ec 04             	sub    $0x4,%esp
c0106efd:	6a 01                	push   $0x1
c0106eff:	68 00 10 00 00       	push   $0x1000
c0106f04:	50                   	push   %eax
c0106f05:	e8 e8 e6 ff ff       	call   c01055f2 <get_pte>
c0106f0a:	83 c4 10             	add    $0x10,%esp
c0106f0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106f10:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106f14:	75 19                	jne    c0106f2f <check_swap+0x1f4>
c0106f16:	68 64 cc 10 c0       	push   $0xc010cc64
c0106f1b:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106f20:	68 d6 00 00 00       	push   $0xd6
c0106f25:	68 40 ca 10 c0       	push   $0xc010ca40
c0106f2a:	e8 57 9e ff ff       	call   c0100d86 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106f2f:	83 ec 0c             	sub    $0xc,%esp
c0106f32:	68 78 cc 10 c0       	push   $0xc010cc78
c0106f37:	e8 0c 94 ff ff       	call   c0100348 <cprintf>
c0106f3c:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106f3f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106f46:	e9 8e 00 00 00       	jmp    c0106fd9 <check_swap+0x29e>
          check_rp[i] = alloc_page();
c0106f4b:	83 ec 0c             	sub    $0xc,%esp
c0106f4e:	6a 01                	push   $0x1
c0106f50:	e8 4e e0 ff ff       	call   c0104fa3 <alloc_pages>
c0106f55:	83 c4 10             	add    $0x10,%esp
c0106f58:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f5b:	89 04 95 cc 40 1a c0 	mov    %eax,-0x3fe5bf34(,%edx,4)
          assert(check_rp[i] != NULL );
c0106f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f65:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c0106f6c:	85 c0                	test   %eax,%eax
c0106f6e:	75 19                	jne    c0106f89 <check_swap+0x24e>
c0106f70:	68 9c cc 10 c0       	push   $0xc010cc9c
c0106f75:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106f7a:	68 db 00 00 00       	push   $0xdb
c0106f7f:	68 40 ca 10 c0       	push   $0xc010ca40
c0106f84:	e8 fd 9d ff ff       	call   c0100d86 <__panic>
          assert(!PageProperty(check_rp[i]));
c0106f89:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f8c:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c0106f93:	83 c0 04             	add    $0x4,%eax
c0106f96:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106f9d:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106fa0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106fa3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106fa6:	0f a3 10             	bt     %edx,(%eax)
c0106fa9:	19 c0                	sbb    %eax,%eax
c0106fab:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106fae:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106fb2:	0f 95 c0             	setne  %al
c0106fb5:	0f b6 c0             	movzbl %al,%eax
c0106fb8:	85 c0                	test   %eax,%eax
c0106fba:	74 19                	je     c0106fd5 <check_swap+0x29a>
c0106fbc:	68 b0 cc 10 c0       	push   $0xc010ccb0
c0106fc1:	68 a6 ca 10 c0       	push   $0xc010caa6
c0106fc6:	68 dc 00 00 00       	push   $0xdc
c0106fcb:	68 40 ca 10 c0       	push   $0xc010ca40
c0106fd0:	e8 b1 9d ff ff       	call   c0100d86 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106fd5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106fd9:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106fdd:	0f 8e 68 ff ff ff    	jle    c0106f4b <check_swap+0x210>
     }
     list_entry_t free_list_store = free_list;
c0106fe3:	a1 84 3f 1a c0       	mov    0xc01a3f84,%eax
c0106fe8:	8b 15 88 3f 1a c0    	mov    0xc01a3f88,%edx
c0106fee:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106ff1:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106ff4:	c7 45 a4 84 3f 1a c0 	movl   $0xc01a3f84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106ffb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106ffe:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0107001:	89 50 04             	mov    %edx,0x4(%eax)
c0107004:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107007:	8b 50 04             	mov    0x4(%eax),%edx
c010700a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010700d:	89 10                	mov    %edx,(%eax)
}
c010700f:	90                   	nop
c0107010:	c7 45 a8 84 3f 1a c0 	movl   $0xc01a3f84,-0x58(%ebp)
    return list->next == list;
c0107017:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010701a:	8b 40 04             	mov    0x4(%eax),%eax
c010701d:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0107020:	0f 94 c0             	sete   %al
c0107023:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0107026:	85 c0                	test   %eax,%eax
c0107028:	75 19                	jne    c0107043 <check_swap+0x308>
c010702a:	68 cb cc 10 c0       	push   $0xc010cccb
c010702f:	68 a6 ca 10 c0       	push   $0xc010caa6
c0107034:	68 e0 00 00 00       	push   $0xe0
c0107039:	68 40 ca 10 c0       	push   $0xc010ca40
c010703e:	e8 43 9d ff ff       	call   c0100d86 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0107043:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0107048:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c010704b:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c0107052:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107055:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010705c:	eb 1c                	jmp    c010707a <check_swap+0x33f>
        free_pages(check_rp[i],1);
c010705e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107061:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c0107068:	83 ec 08             	sub    $0x8,%esp
c010706b:	6a 01                	push   $0x1
c010706d:	50                   	push   %eax
c010706e:	e8 9c df ff ff       	call   c010500f <free_pages>
c0107073:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107076:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010707a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010707e:	7e de                	jle    c010705e <check_swap+0x323>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107080:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0107085:	83 f8 04             	cmp    $0x4,%eax
c0107088:	74 19                	je     c01070a3 <check_swap+0x368>
c010708a:	68 e4 cc 10 c0       	push   $0xc010cce4
c010708f:	68 a6 ca 10 c0       	push   $0xc010caa6
c0107094:	68 e9 00 00 00       	push   $0xe9
c0107099:	68 40 ca 10 c0       	push   $0xc010ca40
c010709e:	e8 e3 9c ff ff       	call   c0100d86 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01070a3:	83 ec 0c             	sub    $0xc,%esp
c01070a6:	68 08 cd 10 c0       	push   $0xc010cd08
c01070ab:	e8 98 92 ff ff       	call   c0100348 <cprintf>
c01070b0:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01070b3:	c7 05 10 41 1a c0 00 	movl   $0x0,0xc01a4110
c01070ba:	00 00 00 
     
     check_content_set();
c01070bd:	e8 00 fb ff ff       	call   c0106bc2 <check_content_set>
     assert( nr_free == 0);         
c01070c2:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c01070c7:	85 c0                	test   %eax,%eax
c01070c9:	74 19                	je     c01070e4 <check_swap+0x3a9>
c01070cb:	68 2f cd 10 c0       	push   $0xc010cd2f
c01070d0:	68 a6 ca 10 c0       	push   $0xc010caa6
c01070d5:	68 f2 00 00 00       	push   $0xf2
c01070da:	68 40 ca 10 c0       	push   $0xc010ca40
c01070df:	e8 a2 9c ff ff       	call   c0100d86 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01070e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01070eb:	eb 26                	jmp    c0107113 <check_swap+0x3d8>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01070ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01070f0:	c7 04 85 60 40 1a c0 	movl   $0xffffffff,-0x3fe5bfa0(,%eax,4)
c01070f7:	ff ff ff ff 
c01070fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01070fe:	8b 14 85 60 40 1a c0 	mov    -0x3fe5bfa0(,%eax,4),%edx
c0107105:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107108:	89 14 85 a0 40 1a c0 	mov    %edx,-0x3fe5bf60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010710f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107113:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0107117:	7e d4                	jle    c01070ed <check_swap+0x3b2>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107119:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107120:	e9 c8 00 00 00       	jmp    c01071ed <check_swap+0x4b2>
         check_ptep[i]=0;
c0107125:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107128:	c7 04 85 dc 40 1a c0 	movl   $0x0,-0x3fe5bf24(,%eax,4)
c010712f:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0107133:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107136:	83 c0 01             	add    $0x1,%eax
c0107139:	c1 e0 0c             	shl    $0xc,%eax
c010713c:	83 ec 04             	sub    $0x4,%esp
c010713f:	6a 00                	push   $0x0
c0107141:	50                   	push   %eax
c0107142:	ff 75 e0             	pushl  -0x20(%ebp)
c0107145:	e8 a8 e4 ff ff       	call   c01055f2 <get_pte>
c010714a:	83 c4 10             	add    $0x10,%esp
c010714d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107150:	89 04 95 dc 40 1a c0 	mov    %eax,-0x3fe5bf24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0107157:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010715a:	8b 04 85 dc 40 1a c0 	mov    -0x3fe5bf24(,%eax,4),%eax
c0107161:	85 c0                	test   %eax,%eax
c0107163:	75 19                	jne    c010717e <check_swap+0x443>
c0107165:	68 3c cd 10 c0       	push   $0xc010cd3c
c010716a:	68 a6 ca 10 c0       	push   $0xc010caa6
c010716f:	68 fa 00 00 00       	push   $0xfa
c0107174:	68 40 ca 10 c0       	push   $0xc010ca40
c0107179:	e8 08 9c ff ff       	call   c0100d86 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010717e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107181:	8b 04 85 dc 40 1a c0 	mov    -0x3fe5bf24(,%eax,4),%eax
c0107188:	8b 00                	mov    (%eax),%eax
c010718a:	83 ec 0c             	sub    $0xc,%esp
c010718d:	50                   	push   %eax
c010718e:	e8 dd f6 ff ff       	call   c0106870 <pte2page>
c0107193:	83 c4 10             	add    $0x10,%esp
c0107196:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107199:	8b 14 95 cc 40 1a c0 	mov    -0x3fe5bf34(,%edx,4),%edx
c01071a0:	39 d0                	cmp    %edx,%eax
c01071a2:	74 19                	je     c01071bd <check_swap+0x482>
c01071a4:	68 54 cd 10 c0       	push   $0xc010cd54
c01071a9:	68 a6 ca 10 c0       	push   $0xc010caa6
c01071ae:	68 fb 00 00 00       	push   $0xfb
c01071b3:	68 40 ca 10 c0       	push   $0xc010ca40
c01071b8:	e8 c9 9b ff ff       	call   c0100d86 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01071bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071c0:	8b 04 85 dc 40 1a c0 	mov    -0x3fe5bf24(,%eax,4),%eax
c01071c7:	8b 00                	mov    (%eax),%eax
c01071c9:	83 e0 01             	and    $0x1,%eax
c01071cc:	85 c0                	test   %eax,%eax
c01071ce:	75 19                	jne    c01071e9 <check_swap+0x4ae>
c01071d0:	68 7c cd 10 c0       	push   $0xc010cd7c
c01071d5:	68 a6 ca 10 c0       	push   $0xc010caa6
c01071da:	68 fc 00 00 00       	push   $0xfc
c01071df:	68 40 ca 10 c0       	push   $0xc010ca40
c01071e4:	e8 9d 9b ff ff       	call   c0100d86 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01071e9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01071ed:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01071f1:	0f 8e 2e ff ff ff    	jle    c0107125 <check_swap+0x3ea>
     }
     cprintf("set up init env for check_swap over!\n");
c01071f7:	83 ec 0c             	sub    $0xc,%esp
c01071fa:	68 98 cd 10 c0       	push   $0xc010cd98
c01071ff:	e8 44 91 ff ff       	call   c0100348 <cprintf>
c0107204:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0107207:	e8 17 fb ff ff       	call   c0106d23 <check_content_access>
c010720c:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c010720f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107213:	74 19                	je     c010722e <check_swap+0x4f3>
c0107215:	68 be cd 10 c0       	push   $0xc010cdbe
c010721a:	68 a6 ca 10 c0       	push   $0xc010caa6
c010721f:	68 01 01 00 00       	push   $0x101
c0107224:	68 40 ca 10 c0       	push   $0xc010ca40
c0107229:	e8 58 9b ff ff       	call   c0100d86 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010722e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107235:	eb 1c                	jmp    c0107253 <check_swap+0x518>
         free_pages(check_rp[i],1);
c0107237:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010723a:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c0107241:	83 ec 08             	sub    $0x8,%esp
c0107244:	6a 01                	push   $0x1
c0107246:	50                   	push   %eax
c0107247:	e8 c3 dd ff ff       	call   c010500f <free_pages>
c010724c:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010724f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107253:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107257:	7e de                	jle    c0107237 <check_swap+0x4fc>
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0107259:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010725c:	8b 00                	mov    (%eax),%eax
c010725e:	83 ec 0c             	sub    $0xc,%esp
c0107261:	50                   	push   %eax
c0107262:	e8 43 f6 ff ff       	call   c01068aa <pde2page>
c0107267:	83 c4 10             	add    $0x10,%esp
c010726a:	83 ec 08             	sub    $0x8,%esp
c010726d:	6a 01                	push   $0x1
c010726f:	50                   	push   %eax
c0107270:	e8 9a dd ff ff       	call   c010500f <free_pages>
c0107275:	83 c4 10             	add    $0x10,%esp
     pgdir[0] = 0;
c0107278:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010727b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c0107281:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107284:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c010728b:	83 ec 0c             	sub    $0xc,%esp
c010728e:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107291:	e8 e2 09 00 00       	call   c0107c78 <mm_destroy>
c0107296:	83 c4 10             	add    $0x10,%esp
     check_mm_struct = NULL;
c0107299:	c7 05 0c 41 1a c0 00 	movl   $0x0,0xc01a410c
c01072a0:	00 00 00 
     
     nr_free = nr_free_store;
c01072a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01072a6:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
     free_list = free_list_store;
c01072ab:	8b 45 98             	mov    -0x68(%ebp),%eax
c01072ae:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01072b1:	a3 84 3f 1a c0       	mov    %eax,0xc01a3f84
c01072b6:	89 15 88 3f 1a c0    	mov    %edx,0xc01a3f88

     
     le = &free_list;
c01072bc:	c7 45 e8 84 3f 1a c0 	movl   $0xc01a3f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01072c3:	eb 1d                	jmp    c01072e2 <check_swap+0x5a7>
         struct Page *p = le2page(le, page_link);
c01072c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01072c8:	83 e8 0c             	sub    $0xc,%eax
c01072cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c01072ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01072d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01072d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01072d8:	8b 48 08             	mov    0x8(%eax),%ecx
c01072db:	89 d0                	mov    %edx,%eax
c01072dd:	29 c8                	sub    %ecx,%eax
c01072df:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01072e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01072e5:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c01072e8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01072eb:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01072ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01072f1:	81 7d e8 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x18(%ebp)
c01072f8:	75 cb                	jne    c01072c5 <check_swap+0x58a>
     }
     cprintf("count is %d, total is %d\n",count,total);
c01072fa:	83 ec 04             	sub    $0x4,%esp
c01072fd:	ff 75 f0             	pushl  -0x10(%ebp)
c0107300:	ff 75 f4             	pushl  -0xc(%ebp)
c0107303:	68 c5 cd 10 c0       	push   $0xc010cdc5
c0107308:	e8 3b 90 ff ff       	call   c0100348 <cprintf>
c010730d:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107310:	83 ec 0c             	sub    $0xc,%esp
c0107313:	68 df cd 10 c0       	push   $0xc010cddf
c0107318:	e8 2b 90 ff ff       	call   c0100348 <cprintf>
c010731d:	83 c4 10             	add    $0x10,%esp
}
c0107320:	90                   	nop
c0107321:	c9                   	leave  
c0107322:	c3                   	ret    

c0107323 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
c0107323:	55                   	push   %ebp
c0107324:	89 e5                	mov    %esp,%ebp
c0107326:	83 ec 10             	sub    $0x10,%esp
c0107329:	c7 45 fc 04 41 1a c0 	movl   $0xc01a4104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107330:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107333:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107336:	89 50 04             	mov    %edx,0x4(%eax)
c0107339:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010733c:	8b 50 04             	mov    0x4(%eax),%edx
c010733f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107342:	89 10                	mov    %edx,(%eax)
}
c0107344:	90                   	nop
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
c0107345:	8b 45 08             	mov    0x8(%ebp),%eax
c0107348:	c7 40 14 04 41 1a c0 	movl   $0xc01a4104,0x14(%eax)
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
c010734f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107354:	c9                   	leave  
c0107355:	c3                   	ret    

c0107356 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107356:	55                   	push   %ebp
c0107357:	89 e5                	mov    %esp,%ebp
c0107359:	83 ec 28             	sub    $0x28,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c010735c:	8b 45 08             	mov    0x8(%ebp),%eax
c010735f:	8b 40 14             	mov    0x14(%eax),%eax
c0107362:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry = &(page->pra_page_link);
c0107365:	8b 45 10             	mov    0x10(%ebp),%eax
c0107368:	83 c0 14             	add    $0x14,%eax
c010736b:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert(entry != NULL && head != NULL);
c010736e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107372:	74 06                	je     c010737a <_fifo_map_swappable+0x24>
c0107374:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107378:	75 16                	jne    c0107390 <_fifo_map_swappable+0x3a>
c010737a:	68 f8 cd 10 c0       	push   $0xc010cdf8
c010737f:	68 16 ce 10 c0       	push   $0xc010ce16
c0107384:	6a 32                	push   $0x32
c0107386:	68 2b ce 10 c0       	push   $0xc010ce2b
c010738b:	e8 f6 99 ff ff       	call   c0100d86 <__panic>
c0107390:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107393:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107396:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107399:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010739c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010739f:	8b 00                	mov    (%eax),%eax
c01073a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01073a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01073a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01073aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c01073b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01073b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01073b6:	89 10                	mov    %edx,(%eax)
c01073b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01073bb:	8b 10                	mov    (%eax),%edx
c01073bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01073c0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01073c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01073c9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01073cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01073d2:	89 10                	mov    %edx,(%eax)
}
c01073d4:	90                   	nop
}
c01073d5:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add_before(head, entry);
    return 0;
c01073d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073db:	c9                   	leave  
c01073dc:	c3                   	ret    

c01073dd <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c01073dd:	55                   	push   %ebp
c01073de:	89 e5                	mov    %esp,%ebp
c01073e0:	83 ec 28             	sub    $0x28,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c01073e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01073e6:	8b 40 14             	mov    0x14(%eax),%eax
c01073e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c01073ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01073f0:	75 16                	jne    c0107408 <_fifo_swap_out_victim+0x2b>
c01073f2:	68 3f ce 10 c0       	push   $0xc010ce3f
c01073f7:	68 16 ce 10 c0       	push   $0xc010ce16
c01073fc:	6a 41                	push   $0x41
c01073fe:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107403:	e8 7e 99 ff ff       	call   c0100d86 <__panic>
    assert(in_tick == 0);
c0107408:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010740c:	74 16                	je     c0107424 <_fifo_swap_out_victim+0x47>
c010740e:	68 4c ce 10 c0       	push   $0xc010ce4c
c0107413:	68 16 ce 10 c0       	push   $0xc010ce16
c0107418:	6a 42                	push   $0x42
c010741a:	68 2b ce 10 c0       	push   $0xc010ce2b
c010741f:	e8 62 99 ff ff       	call   c0100d86 <__panic>
c0107424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107427:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c010742a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010742d:	8b 40 04             	mov    0x4(%eax),%eax
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  assign the value of *ptr_page to the addr of this page
    list_entry_t *le = list_next(head);
c0107430:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107433:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107436:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107439:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010743c:	8b 40 04             	mov    0x4(%eax),%eax
c010743f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107442:	8b 12                	mov    (%edx),%edx
c0107444:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c010744a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010744d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107450:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107453:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107456:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107459:	89 10                	mov    %edx,(%eax)
}
c010745b:	90                   	nop
}
c010745c:	90                   	nop
    list_del(le); //victim
    *ptr_page = le2page(le, pra_page_link);
c010745d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107460:	8d 50 ec             	lea    -0x14(%eax),%edx
c0107463:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107466:	89 10                	mov    %edx,(%eax)
    return 0;
c0107468:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010746d:	c9                   	leave  
c010746e:	c3                   	ret    

c010746f <_extend_clock_swap_out_victim>:

static int
_extend_clock_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c010746f:	55                   	push   %ebp
c0107470:	89 e5                	mov    %esp,%ebp
c0107472:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0107475:	8b 45 08             	mov    0x8(%ebp),%eax
c0107478:	8b 40 14             	mov    0x14(%eax),%eax
c010747b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(head != NULL);
c010747e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107482:	75 16                	jne    c010749a <_extend_clock_swap_out_victim+0x2b>
c0107484:	68 3f ce 10 c0       	push   $0xc010ce3f
c0107489:	68 16 ce 10 c0       	push   $0xc010ce16
c010748e:	6a 51                	push   $0x51
c0107490:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107495:	e8 ec 98 ff ff       	call   c0100d86 <__panic>
    assert(in_tick == 0);
c010749a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010749e:	74 16                	je     c01074b6 <_extend_clock_swap_out_victim+0x47>
c01074a0:	68 4c ce 10 c0       	push   $0xc010ce4c
c01074a5:	68 16 ce 10 c0       	push   $0xc010ce16
c01074aa:	6a 52                	push   $0x52
c01074ac:	68 2b ce 10 c0       	push   $0xc010ce2b
c01074b1:	e8 d0 98 ff ff       	call   c0100d86 <__panic>
    //在head双向链表中从头开始遍历, 用三个指针取三个第一次遍历到的page
    list_entry_t *le = head->next, *_00 = NULL, *_10 = NULL, *_11 = NULL;
c01074b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074b9:	8b 40 04             	mov    0x4(%eax),%eax
c01074bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01074bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01074c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01074cd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while (le != head)
c01074d4:	e9 86 00 00 00       	jmp    c010755f <_extend_clock_swap_out_victim+0xf0>
    {
        struct Page *page = le2page(le, pra_page_link);
c01074d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074dc:	83 e8 14             	sub    $0x14,%eax
c01074df:	89 45 e0             	mov    %eax,-0x20(%ebp)

        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
c01074e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01074e5:	8b 50 1c             	mov    0x1c(%eax),%edx
c01074e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01074eb:	8b 40 0c             	mov    0xc(%eax),%eax
c01074ee:	83 ec 04             	sub    $0x4,%esp
c01074f1:	6a 00                	push   $0x0
c01074f3:	52                   	push   %edx
c01074f4:	50                   	push   %eax
c01074f5:	e8 f8 e0 ff ff       	call   c01055f2 <get_pte>
c01074fa:	83 c4 10             	add    $0x10,%esp
c01074fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ptep != NULL);
c0107500:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107504:	75 16                	jne    c010751c <_extend_clock_swap_out_victim+0xad>
c0107506:	68 59 ce 10 c0       	push   $0xc010ce59
c010750b:	68 16 ce 10 c0       	push   $0xc010ce16
c0107510:	6a 5a                	push   $0x5a
c0107512:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107517:	e8 6a 98 ff ff       	call   c0100d86 <__panic>
        if (!(*ptep & PTE_A))
c010751c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010751f:	8b 00                	mov    (%eax),%eax
c0107521:	83 e0 20             	and    $0x20,%eax
c0107524:	85 c0                	test   %eax,%eax
c0107526:	75 08                	jne    c0107530 <_extend_clock_swap_out_victim+0xc1>
        {
            _00 = le;
c0107528:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010752b:	89 45 f0             	mov    %eax,-0x10(%ebp)
            break;
c010752e:	eb 3b                	jmp    c010756b <_extend_clock_swap_out_victim+0xfc>
        }
        else if (!(*ptep & PTE_D) && _10 == NULL)
c0107530:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107533:	8b 00                	mov    (%eax),%eax
c0107535:	83 e0 40             	and    $0x40,%eax
c0107538:	85 c0                	test   %eax,%eax
c010753a:	75 0e                	jne    c010754a <_extend_clock_swap_out_victim+0xdb>
c010753c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107540:	75 08                	jne    c010754a <_extend_clock_swap_out_victim+0xdb>
            _10 = le;
c0107542:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107545:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107548:	eb 0c                	jmp    c0107556 <_extend_clock_swap_out_victim+0xe7>
        else if (_11 == NULL)
c010754a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010754e:	75 06                	jne    c0107556 <_extend_clock_swap_out_victim+0xe7>
            _11 = le;
c0107550:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107553:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = le->next;
c0107556:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107559:	8b 40 04             	mov    0x4(%eax),%eax
c010755c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != head)
c010755f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107562:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c0107565:	0f 85 6e ff ff ff    	jne    c01074d9 <_extend_clock_swap_out_victim+0x6a>
    }
    le = _00 != NULL ? _00 : (_10 != NULL ? _10 : _11);
c010756b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010756f:	75 10                	jne    c0107581 <_extend_clock_swap_out_victim+0x112>
c0107571:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107575:	74 05                	je     c010757c <_extend_clock_swap_out_victim+0x10d>
c0107577:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010757a:	eb 08                	jmp    c0107584 <_extend_clock_swap_out_victim+0x115>
c010757c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010757f:	eb 03                	jmp    c0107584 <_extend_clock_swap_out_victim+0x115>
c0107581:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107584:	89 45 f4             	mov    %eax,-0xc(%ebp)
    *ptr_page = le2page(le, pra_page_link);
c0107587:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010758a:	8d 50 ec             	lea    -0x14(%eax),%edx
c010758d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107590:	89 10                	mov    %edx,(%eax)
c0107592:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107595:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107598:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010759b:	8b 40 04             	mov    0x4(%eax),%eax
c010759e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01075a1:	8b 12                	mov    (%edx),%edx
c01075a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01075a6:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next;
c01075a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01075ac:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01075af:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01075b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01075b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01075b8:	89 10                	mov    %edx,(%eax)
}
c01075ba:	90                   	nop
}
c01075bb:	90                   	nop
    list_del(le);
    return 0;
c01075bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075c1:	c9                   	leave  
c01075c2:	c3                   	ret    

c01075c3 <_fifo_check_swap>:

static int
_fifo_check_swap(void)
{
c01075c3:	55                   	push   %ebp
c01075c4:	89 e5                	mov    %esp,%ebp
c01075c6:	83 ec 08             	sub    $0x8,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01075c9:	83 ec 0c             	sub    $0xc,%esp
c01075cc:	68 68 ce 10 c0       	push   $0xc010ce68
c01075d1:	e8 72 8d ff ff       	call   c0100348 <cprintf>
c01075d6:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c01075d9:	b8 00 30 00 00       	mov    $0x3000,%eax
c01075de:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 4);
c01075e1:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01075e6:	83 f8 04             	cmp    $0x4,%eax
c01075e9:	74 16                	je     c0107601 <_fifo_check_swap+0x3e>
c01075eb:	68 8e ce 10 c0       	push   $0xc010ce8e
c01075f0:	68 16 ce 10 c0       	push   $0xc010ce16
c01075f5:	6a 71                	push   $0x71
c01075f7:	68 2b ce 10 c0       	push   $0xc010ce2b
c01075fc:	e8 85 97 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107601:	83 ec 0c             	sub    $0xc,%esp
c0107604:	68 a0 ce 10 c0       	push   $0xc010cea0
c0107609:	e8 3a 8d ff ff       	call   c0100348 <cprintf>
c010760e:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0107611:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107616:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 4);
c0107619:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c010761e:	83 f8 04             	cmp    $0x4,%eax
c0107621:	74 16                	je     c0107639 <_fifo_check_swap+0x76>
c0107623:	68 8e ce 10 c0       	push   $0xc010ce8e
c0107628:	68 16 ce 10 c0       	push   $0xc010ce16
c010762d:	6a 74                	push   $0x74
c010762f:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107634:	e8 4d 97 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107639:	83 ec 0c             	sub    $0xc,%esp
c010763c:	68 c8 ce 10 c0       	push   $0xc010cec8
c0107641:	e8 02 8d ff ff       	call   c0100348 <cprintf>
c0107646:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c0107649:	b8 00 40 00 00       	mov    $0x4000,%eax
c010764e:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 4);
c0107651:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107656:	83 f8 04             	cmp    $0x4,%eax
c0107659:	74 16                	je     c0107671 <_fifo_check_swap+0xae>
c010765b:	68 8e ce 10 c0       	push   $0xc010ce8e
c0107660:	68 16 ce 10 c0       	push   $0xc010ce16
c0107665:	6a 77                	push   $0x77
c0107667:	68 2b ce 10 c0       	push   $0xc010ce2b
c010766c:	e8 15 97 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107671:	83 ec 0c             	sub    $0xc,%esp
c0107674:	68 f0 ce 10 c0       	push   $0xc010cef0
c0107679:	e8 ca 8c ff ff       	call   c0100348 <cprintf>
c010767e:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0107681:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107686:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 4);
c0107689:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c010768e:	83 f8 04             	cmp    $0x4,%eax
c0107691:	74 16                	je     c01076a9 <_fifo_check_swap+0xe6>
c0107693:	68 8e ce 10 c0       	push   $0xc010ce8e
c0107698:	68 16 ce 10 c0       	push   $0xc010ce16
c010769d:	6a 7a                	push   $0x7a
c010769f:	68 2b ce 10 c0       	push   $0xc010ce2b
c01076a4:	e8 dd 96 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01076a9:	83 ec 0c             	sub    $0xc,%esp
c01076ac:	68 18 cf 10 c0       	push   $0xc010cf18
c01076b1:	e8 92 8c ff ff       	call   c0100348 <cprintf>
c01076b6:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c01076b9:	b8 00 50 00 00       	mov    $0x5000,%eax
c01076be:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 5);
c01076c1:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01076c6:	83 f8 05             	cmp    $0x5,%eax
c01076c9:	74 16                	je     c01076e1 <_fifo_check_swap+0x11e>
c01076cb:	68 3e cf 10 c0       	push   $0xc010cf3e
c01076d0:	68 16 ce 10 c0       	push   $0xc010ce16
c01076d5:	6a 7d                	push   $0x7d
c01076d7:	68 2b ce 10 c0       	push   $0xc010ce2b
c01076dc:	e8 a5 96 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01076e1:	83 ec 0c             	sub    $0xc,%esp
c01076e4:	68 f0 ce 10 c0       	push   $0xc010cef0
c01076e9:	e8 5a 8c ff ff       	call   c0100348 <cprintf>
c01076ee:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c01076f1:	b8 00 20 00 00       	mov    $0x2000,%eax
c01076f6:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 5);
c01076f9:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01076fe:	83 f8 05             	cmp    $0x5,%eax
c0107701:	74 19                	je     c010771c <_fifo_check_swap+0x159>
c0107703:	68 3e cf 10 c0       	push   $0xc010cf3e
c0107708:	68 16 ce 10 c0       	push   $0xc010ce16
c010770d:	68 80 00 00 00       	push   $0x80
c0107712:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107717:	e8 6a 96 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010771c:	83 ec 0c             	sub    $0xc,%esp
c010771f:	68 a0 ce 10 c0       	push   $0xc010cea0
c0107724:	e8 1f 8c ff ff       	call   c0100348 <cprintf>
c0107729:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c010772c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107731:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 6);
c0107734:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107739:	83 f8 06             	cmp    $0x6,%eax
c010773c:	74 19                	je     c0107757 <_fifo_check_swap+0x194>
c010773e:	68 4f cf 10 c0       	push   $0xc010cf4f
c0107743:	68 16 ce 10 c0       	push   $0xc010ce16
c0107748:	68 83 00 00 00       	push   $0x83
c010774d:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107752:	e8 2f 96 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107757:	83 ec 0c             	sub    $0xc,%esp
c010775a:	68 f0 ce 10 c0       	push   $0xc010cef0
c010775f:	e8 e4 8b ff ff       	call   c0100348 <cprintf>
c0107764:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0107767:	b8 00 20 00 00       	mov    $0x2000,%eax
c010776c:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 7);
c010776f:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107774:	83 f8 07             	cmp    $0x7,%eax
c0107777:	74 19                	je     c0107792 <_fifo_check_swap+0x1cf>
c0107779:	68 60 cf 10 c0       	push   $0xc010cf60
c010777e:	68 16 ce 10 c0       	push   $0xc010ce16
c0107783:	68 86 00 00 00       	push   $0x86
c0107788:	68 2b ce 10 c0       	push   $0xc010ce2b
c010778d:	e8 f4 95 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107792:	83 ec 0c             	sub    $0xc,%esp
c0107795:	68 68 ce 10 c0       	push   $0xc010ce68
c010779a:	e8 a9 8b ff ff       	call   c0100348 <cprintf>
c010779f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c01077a2:	b8 00 30 00 00       	mov    $0x3000,%eax
c01077a7:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 8);
c01077aa:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01077af:	83 f8 08             	cmp    $0x8,%eax
c01077b2:	74 19                	je     c01077cd <_fifo_check_swap+0x20a>
c01077b4:	68 71 cf 10 c0       	push   $0xc010cf71
c01077b9:	68 16 ce 10 c0       	push   $0xc010ce16
c01077be:	68 89 00 00 00       	push   $0x89
c01077c3:	68 2b ce 10 c0       	push   $0xc010ce2b
c01077c8:	e8 b9 95 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01077cd:	83 ec 0c             	sub    $0xc,%esp
c01077d0:	68 c8 ce 10 c0       	push   $0xc010cec8
c01077d5:	e8 6e 8b ff ff       	call   c0100348 <cprintf>
c01077da:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c01077dd:	b8 00 40 00 00       	mov    $0x4000,%eax
c01077e2:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 9);
c01077e5:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01077ea:	83 f8 09             	cmp    $0x9,%eax
c01077ed:	74 19                	je     c0107808 <_fifo_check_swap+0x245>
c01077ef:	68 82 cf 10 c0       	push   $0xc010cf82
c01077f4:	68 16 ce 10 c0       	push   $0xc010ce16
c01077f9:	68 8c 00 00 00       	push   $0x8c
c01077fe:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107803:	e8 7e 95 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107808:	83 ec 0c             	sub    $0xc,%esp
c010780b:	68 18 cf 10 c0       	push   $0xc010cf18
c0107810:	e8 33 8b ff ff       	call   c0100348 <cprintf>
c0107815:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c0107818:	b8 00 50 00 00       	mov    $0x5000,%eax
c010781d:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 10);
c0107820:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107825:	83 f8 0a             	cmp    $0xa,%eax
c0107828:	74 19                	je     c0107843 <_fifo_check_swap+0x280>
c010782a:	68 93 cf 10 c0       	push   $0xc010cf93
c010782f:	68 16 ce 10 c0       	push   $0xc010ce16
c0107834:	68 8f 00 00 00       	push   $0x8f
c0107839:	68 2b ce 10 c0       	push   $0xc010ce2b
c010783e:	e8 43 95 ff ff       	call   c0100d86 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107843:	83 ec 0c             	sub    $0xc,%esp
c0107846:	68 a0 ce 10 c0       	push   $0xc010cea0
c010784b:	e8 f8 8a ff ff       	call   c0100348 <cprintf>
c0107850:	83 c4 10             	add    $0x10,%esp
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107853:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107858:	0f b6 00             	movzbl (%eax),%eax
c010785b:	3c 0a                	cmp    $0xa,%al
c010785d:	74 19                	je     c0107878 <_fifo_check_swap+0x2b5>
c010785f:	68 a8 cf 10 c0       	push   $0xc010cfa8
c0107864:	68 16 ce 10 c0       	push   $0xc010ce16
c0107869:	68 91 00 00 00       	push   $0x91
c010786e:	68 2b ce 10 c0       	push   $0xc010ce2b
c0107873:	e8 0e 95 ff ff       	call   c0100d86 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107878:	b8 00 10 00 00       	mov    $0x1000,%eax
c010787d:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 11);
c0107880:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107885:	83 f8 0b             	cmp    $0xb,%eax
c0107888:	74 19                	je     c01078a3 <_fifo_check_swap+0x2e0>
c010788a:	68 c9 cf 10 c0       	push   $0xc010cfc9
c010788f:	68 16 ce 10 c0       	push   $0xc010ce16
c0107894:	68 93 00 00 00       	push   $0x93
c0107899:	68 2b ce 10 c0       	push   $0xc010ce2b
c010789e:	e8 e3 94 ff ff       	call   c0100d86 <__panic>
    return 0;
c01078a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01078a8:	c9                   	leave  
c01078a9:	c3                   	ret    

c01078aa <_fifo_init>:

static int
_fifo_init(void)
{
c01078aa:	55                   	push   %ebp
c01078ab:	89 e5                	mov    %esp,%ebp
    return 0;
c01078ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01078b2:	5d                   	pop    %ebp
c01078b3:	c3                   	ret    

c01078b4 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01078b4:	55                   	push   %ebp
c01078b5:	89 e5                	mov    %esp,%ebp
    return 0;
c01078b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01078bc:	5d                   	pop    %ebp
c01078bd:	c3                   	ret    

c01078be <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
c01078be:	55                   	push   %ebp
c01078bf:	89 e5                	mov    %esp,%ebp
    return 0;
c01078c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01078c6:	5d                   	pop    %ebp
c01078c7:	c3                   	ret    

c01078c8 <pa2page>:
pa2page(uintptr_t pa) {
c01078c8:	55                   	push   %ebp
c01078c9:	89 e5                	mov    %esp,%ebp
c01078cb:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c01078ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01078d1:	c1 e8 0c             	shr    $0xc,%eax
c01078d4:	89 c2                	mov    %eax,%edx
c01078d6:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01078db:	39 c2                	cmp    %eax,%edx
c01078dd:	72 14                	jb     c01078f3 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c01078df:	83 ec 04             	sub    $0x4,%esp
c01078e2:	68 f0 cf 10 c0       	push   $0xc010cff0
c01078e7:	6a 5e                	push   $0x5e
c01078e9:	68 0f d0 10 c0       	push   $0xc010d00f
c01078ee:	e8 93 94 ff ff       	call   c0100d86 <__panic>
    return &pages[PPN(pa)];
c01078f3:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c01078f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01078fc:	c1 e8 0c             	shr    $0xc,%eax
c01078ff:	c1 e0 05             	shl    $0x5,%eax
c0107902:	01 d0                	add    %edx,%eax
}
c0107904:	c9                   	leave  
c0107905:	c3                   	ret    

c0107906 <pde2page>:
pde2page(pde_t pde) {
c0107906:	55                   	push   %ebp
c0107907:	89 e5                	mov    %esp,%ebp
c0107909:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c010790c:	8b 45 08             	mov    0x8(%ebp),%eax
c010790f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107914:	83 ec 0c             	sub    $0xc,%esp
c0107917:	50                   	push   %eax
c0107918:	e8 ab ff ff ff       	call   c01078c8 <pa2page>
c010791d:	83 c4 10             	add    $0x10,%esp
}
c0107920:	c9                   	leave  
c0107921:	c3                   	ret    

c0107922 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0107922:	55                   	push   %ebp
c0107923:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0107925:	8b 45 08             	mov    0x8(%ebp),%eax
c0107928:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c010792e:	90                   	nop
c010792f:	5d                   	pop    %ebp
c0107930:	c3                   	ret    

c0107931 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0107931:	55                   	push   %ebp
c0107932:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0107934:	8b 45 08             	mov    0x8(%ebp),%eax
c0107937:	8b 40 18             	mov    0x18(%eax),%eax
}
c010793a:	5d                   	pop    %ebp
c010793b:	c3                   	ret    

c010793c <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c010793c:	55                   	push   %ebp
c010793d:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c010793f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107942:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107945:	89 50 18             	mov    %edx,0x18(%eax)
}
c0107948:	90                   	nop
c0107949:	5d                   	pop    %ebp
c010794a:	c3                   	ret    

c010794b <mm_create>:
static void
check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010794b:	55                   	push   %ebp
c010794c:	89 e5                	mov    %esp,%ebp
c010794e:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107951:	83 ec 0c             	sub    $0xc,%esp
c0107954:	6a 20                	push   $0x20
c0107956:	e8 d5 d1 ff ff       	call   c0104b30 <kmalloc>
c010795b:	83 c4 10             	add    $0x10,%esp
c010795e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107961:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107965:	74 7e                	je     c01079e5 <mm_create+0x9a>
        list_init(&(mm->mmap_list));
c0107967:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010796a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c010796d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107970:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107973:	89 50 04             	mov    %edx,0x4(%eax)
c0107976:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107979:	8b 50 04             	mov    0x4(%eax),%edx
c010797c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010797f:	89 10                	mov    %edx,(%eax)
}
c0107981:	90                   	nop
        mm->mmap_cache = NULL;
c0107982:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107985:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c010798c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010798f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107996:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107999:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok)
c01079a0:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c01079a5:	85 c0                	test   %eax,%eax
c01079a7:	74 10                	je     c01079b9 <mm_create+0x6e>
            swap_init_mm(mm);
c01079a9:	83 ec 0c             	sub    $0xc,%esp
c01079ac:	ff 75 f4             	pushl  -0xc(%ebp)
c01079af:	e8 95 ef ff ff       	call   c0106949 <swap_init_mm>
c01079b4:	83 c4 10             	add    $0x10,%esp
c01079b7:	eb 0a                	jmp    c01079c3 <mm_create+0x78>
        else
            mm->sm_priv = NULL;
c01079b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079bc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

        set_mm_count(mm, 0);
c01079c3:	83 ec 08             	sub    $0x8,%esp
c01079c6:	6a 00                	push   $0x0
c01079c8:	ff 75 f4             	pushl  -0xc(%ebp)
c01079cb:	e8 6c ff ff ff       	call   c010793c <set_mm_count>
c01079d0:	83 c4 10             	add    $0x10,%esp
        lock_init(&(mm->mm_lock));
c01079d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079d6:	83 c0 1c             	add    $0x1c,%eax
c01079d9:	83 ec 0c             	sub    $0xc,%esp
c01079dc:	50                   	push   %eax
c01079dd:	e8 40 ff ff ff       	call   c0107922 <lock_init>
c01079e2:	83 c4 10             	add    $0x10,%esp
    }
    return mm;
c01079e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01079e8:	c9                   	leave  
c01079e9:	c3                   	ret    

c01079ea <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01079ea:	55                   	push   %ebp
c01079eb:	89 e5                	mov    %esp,%ebp
c01079ed:	83 ec 18             	sub    $0x18,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01079f0:	83 ec 0c             	sub    $0xc,%esp
c01079f3:	6a 18                	push   $0x18
c01079f5:	e8 36 d1 ff ff       	call   c0104b30 <kmalloc>
c01079fa:	83 c4 10             	add    $0x10,%esp
c01079fd:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0107a00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a04:	74 1b                	je     c0107a21 <vma_create+0x37>
        vma->vm_start = vm_start;
c0107a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a09:	8b 55 08             	mov    0x8(%ebp),%edx
c0107a0c:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0107a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a12:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107a15:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a1b:	8b 55 10             	mov    0x10(%ebp),%edx
c0107a1e:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107a24:	c9                   	leave  
c0107a25:	c3                   	ret    

c0107a26 <find_vma>:

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107a26:	55                   	push   %ebp
c0107a27:	89 e5                	mov    %esp,%ebp
c0107a29:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107a2c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0107a33:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107a37:	0f 84 95 00 00 00    	je     c0107ad2 <find_vma+0xac>
        vma = mm->mmap_cache;
c0107a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a40:	8b 40 08             	mov    0x8(%eax),%eax
c0107a43:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107a46:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107a4a:	74 16                	je     c0107a62 <find_vma+0x3c>
c0107a4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a4f:	8b 40 04             	mov    0x4(%eax),%eax
c0107a52:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107a55:	72 0b                	jb     c0107a62 <find_vma+0x3c>
c0107a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a5a:	8b 40 08             	mov    0x8(%eax),%eax
c0107a5d:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107a60:	72 61                	jb     c0107ac3 <find_vma+0x9d>
            bool found = 0;
c0107a62:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
            list_entry_t *list = &(mm->mmap_list), *le = list;
c0107a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
            while ((le = list_next(le)) != list) {
c0107a75:	eb 28                	jmp    c0107a9f <find_vma+0x79>
                vma = le2vma(le, list_link);
c0107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a7a:	83 e8 10             	sub    $0x10,%eax
c0107a7d:	89 45 fc             	mov    %eax,-0x4(%ebp)
                if (vma->vm_start <= addr && addr < vma->vm_end) {
c0107a80:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a83:	8b 40 04             	mov    0x4(%eax),%eax
c0107a86:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107a89:	72 14                	jb     c0107a9f <find_vma+0x79>
c0107a8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a8e:	8b 40 08             	mov    0x8(%eax),%eax
c0107a91:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107a94:	73 09                	jae    c0107a9f <find_vma+0x79>
                    found = 1;
c0107a96:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                    break;
c0107a9d:	eb 17                	jmp    c0107ab6 <find_vma+0x90>
c0107a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c0107aa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107aa8:	8b 40 04             	mov    0x4(%eax),%eax
            while ((le = list_next(le)) != list) {
c0107aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ab1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107ab4:	75 c1                	jne    c0107a77 <find_vma+0x51>
                }
            }
            if (!found) {
c0107ab6:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0107aba:	75 07                	jne    c0107ac3 <find_vma+0x9d>
                vma = NULL;
c0107abc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
            }
        }
        if (vma != NULL) {
c0107ac3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107ac7:	74 09                	je     c0107ad2 <find_vma+0xac>
            mm->mmap_cache = vma;
c0107ac9:	8b 45 08             	mov    0x8(%ebp),%eax
c0107acc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107acf:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0107ad2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107ad5:	c9                   	leave  
c0107ad6:	c3                   	ret    

c0107ad7 <check_vma_overlap>:

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0107ad7:	55                   	push   %ebp
c0107ad8:	89 e5                	mov    %esp,%ebp
c0107ada:	83 ec 08             	sub    $0x8,%esp
    assert(prev->vm_start < prev->vm_end);
c0107add:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ae0:	8b 50 04             	mov    0x4(%eax),%edx
c0107ae3:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ae6:	8b 40 08             	mov    0x8(%eax),%eax
c0107ae9:	39 c2                	cmp    %eax,%edx
c0107aeb:	72 16                	jb     c0107b03 <check_vma_overlap+0x2c>
c0107aed:	68 1d d0 10 c0       	push   $0xc010d01d
c0107af2:	68 3b d0 10 c0       	push   $0xc010d03b
c0107af7:	6a 6e                	push   $0x6e
c0107af9:	68 50 d0 10 c0       	push   $0xc010d050
c0107afe:	e8 83 92 ff ff       	call   c0100d86 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0107b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b06:	8b 50 08             	mov    0x8(%eax),%edx
c0107b09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b0c:	8b 40 04             	mov    0x4(%eax),%eax
c0107b0f:	39 c2                	cmp    %eax,%edx
c0107b11:	76 16                	jbe    c0107b29 <check_vma_overlap+0x52>
c0107b13:	68 60 d0 10 c0       	push   $0xc010d060
c0107b18:	68 3b d0 10 c0       	push   $0xc010d03b
c0107b1d:	6a 6f                	push   $0x6f
c0107b1f:	68 50 d0 10 c0       	push   $0xc010d050
c0107b24:	e8 5d 92 ff ff       	call   c0100d86 <__panic>
    assert(next->vm_start < next->vm_end);
c0107b29:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b2c:	8b 50 04             	mov    0x4(%eax),%edx
c0107b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b32:	8b 40 08             	mov    0x8(%eax),%eax
c0107b35:	39 c2                	cmp    %eax,%edx
c0107b37:	72 16                	jb     c0107b4f <check_vma_overlap+0x78>
c0107b39:	68 7f d0 10 c0       	push   $0xc010d07f
c0107b3e:	68 3b d0 10 c0       	push   $0xc010d03b
c0107b43:	6a 70                	push   $0x70
c0107b45:	68 50 d0 10 c0       	push   $0xc010d050
c0107b4a:	e8 37 92 ff ff       	call   c0100d86 <__panic>
}
c0107b4f:	90                   	nop
c0107b50:	c9                   	leave  
c0107b51:	c3                   	ret    

c0107b52 <insert_vma_struct>:

// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107b52:	55                   	push   %ebp
c0107b53:	89 e5                	mov    %esp,%ebp
c0107b55:	83 ec 38             	sub    $0x38,%esp
    assert(vma->vm_start < vma->vm_end);
c0107b58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b5b:	8b 50 04             	mov    0x4(%eax),%edx
c0107b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b61:	8b 40 08             	mov    0x8(%eax),%eax
c0107b64:	39 c2                	cmp    %eax,%edx
c0107b66:	72 16                	jb     c0107b7e <insert_vma_struct+0x2c>
c0107b68:	68 9d d0 10 c0       	push   $0xc010d09d
c0107b6d:	68 3b d0 10 c0       	push   $0xc010d03b
c0107b72:	6a 76                	push   $0x76
c0107b74:	68 50 d0 10 c0       	push   $0xc010d050
c0107b79:	e8 08 92 ff ff       	call   c0100d86 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0107b7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b81:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0107b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b87:	89 45 f4             	mov    %eax,-0xc(%ebp)

    list_entry_t *le = list;
c0107b8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while ((le = list_next(le)) != list) {
c0107b90:	eb 1f                	jmp    c0107bb1 <insert_vma_struct+0x5f>
        struct vma_struct *mmap_prev = le2vma(le, list_link);
c0107b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b95:	83 e8 10             	sub    $0x10,%eax
c0107b98:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (mmap_prev->vm_start > vma->vm_start) {
c0107b9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b9e:	8b 50 04             	mov    0x4(%eax),%edx
c0107ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ba4:	8b 40 04             	mov    0x4(%eax),%eax
c0107ba7:	39 c2                	cmp    %eax,%edx
c0107ba9:	77 1f                	ja     c0107bca <insert_vma_struct+0x78>
            break;
        }
        le_prev = le;
c0107bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107bb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107bba:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0107bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bc3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107bc6:	75 ca                	jne    c0107b92 <insert_vma_struct+0x40>
c0107bc8:	eb 01                	jmp    c0107bcb <insert_vma_struct+0x79>
            break;
c0107bca:	90                   	nop
c0107bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bce:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107bd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bd4:	8b 40 04             	mov    0x4(%eax),%eax
    }

    le_next = list_next(le_prev);
c0107bd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0107bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bdd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107be0:	74 15                	je     c0107bf7 <insert_vma_struct+0xa5>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107be5:	83 e8 10             	sub    $0x10,%eax
c0107be8:	83 ec 08             	sub    $0x8,%esp
c0107beb:	ff 75 0c             	pushl  0xc(%ebp)
c0107bee:	50                   	push   %eax
c0107bef:	e8 e3 fe ff ff       	call   c0107ad7 <check_vma_overlap>
c0107bf4:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c0107bf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bfa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107bfd:	74 15                	je     c0107c14 <insert_vma_struct+0xc2>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0107bff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c02:	83 e8 10             	sub    $0x10,%eax
c0107c05:	83 ec 08             	sub    $0x8,%esp
c0107c08:	50                   	push   %eax
c0107c09:	ff 75 0c             	pushl  0xc(%ebp)
c0107c0c:	e8 c6 fe ff ff       	call   c0107ad7 <check_vma_overlap>
c0107c11:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c0107c14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c17:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c1a:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0107c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c1f:	8d 50 10             	lea    0x10(%eax),%edx
c0107c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c25:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107c28:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107c2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c2e:	8b 40 04             	mov    0x4(%eax),%eax
c0107c31:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107c34:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107c37:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107c3a:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0107c3d:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0107c40:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107c43:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107c46:	89 10                	mov    %edx,(%eax)
c0107c48:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107c4b:	8b 10                	mov    (%eax),%edx
c0107c4d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107c50:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107c53:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107c56:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107c59:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107c5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107c5f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107c62:	89 10                	mov    %edx,(%eax)
}
c0107c64:	90                   	nop
}
c0107c65:	90                   	nop

    mm->map_count++;
c0107c66:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c69:	8b 40 10             	mov    0x10(%eax),%eax
c0107c6c:	8d 50 01             	lea    0x1(%eax),%edx
c0107c6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c72:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107c75:	90                   	nop
c0107c76:	c9                   	leave  
c0107c77:	c3                   	ret    

c0107c78 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107c78:	55                   	push   %ebp
c0107c79:	89 e5                	mov    %esp,%ebp
c0107c7b:	83 ec 28             	sub    $0x28,%esp
    assert(mm_count(mm) == 0);
c0107c7e:	ff 75 08             	pushl  0x8(%ebp)
c0107c81:	e8 ab fc ff ff       	call   c0107931 <mm_count>
c0107c86:	83 c4 04             	add    $0x4,%esp
c0107c89:	85 c0                	test   %eax,%eax
c0107c8b:	74 19                	je     c0107ca6 <mm_destroy+0x2e>
c0107c8d:	68 b9 d0 10 c0       	push   $0xc010d0b9
c0107c92:	68 3b d0 10 c0       	push   $0xc010d03b
c0107c97:	68 96 00 00 00       	push   $0x96
c0107c9c:	68 50 d0 10 c0       	push   $0xc010d050
c0107ca1:	e8 e0 90 ff ff       	call   c0100d86 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c0107ca6:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ca9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0107cac:	eb 3c                	jmp    c0107cea <mm_destroy+0x72>
c0107cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107cb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107cb7:	8b 40 04             	mov    0x4(%eax),%eax
c0107cba:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107cbd:	8b 12                	mov    (%edx),%edx
c0107cbf:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107cc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c0107cc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cc8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107ccb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107cce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cd1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107cd4:	89 10                	mov    %edx,(%eax)
}
c0107cd6:	90                   	nop
}
c0107cd7:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma
c0107cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cdb:	83 e8 10             	sub    $0x10,%eax
c0107cde:	83 ec 0c             	sub    $0xc,%esp
c0107ce1:	50                   	push   %eax
c0107ce2:	e8 61 ce ff ff       	call   c0104b48 <kfree>
c0107ce7:	83 c4 10             	add    $0x10,%esp
c0107cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ced:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107cf3:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0107cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cfc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107cff:	75 ad                	jne    c0107cae <mm_destroy+0x36>
    }
    kfree(mm);  //kfree mm
c0107d01:	83 ec 0c             	sub    $0xc,%esp
c0107d04:	ff 75 08             	pushl  0x8(%ebp)
c0107d07:	e8 3c ce ff ff       	call   c0104b48 <kfree>
c0107d0c:	83 c4 10             	add    $0x10,%esp
    mm = NULL;
c0107d0f:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107d16:	90                   	nop
c0107d17:	c9                   	leave  
c0107d18:	c3                   	ret    

c0107d19 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags, struct vma_struct **vma_store) {
c0107d19:	55                   	push   %ebp
c0107d1a:	89 e5                	mov    %esp,%ebp
c0107d1c:	83 ec 28             	sub    $0x28,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c0107d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107d2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107d30:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0107d37:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107d3a:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d3d:	01 c2                	add    %eax,%edx
c0107d3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d42:	01 d0                	add    %edx,%eax
c0107d44:	83 e8 01             	sub    $0x1,%eax
c0107d47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107d4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d4d:	ba 00 00 00 00       	mov    $0x0,%edx
c0107d52:	f7 75 e8             	divl   -0x18(%ebp)
c0107d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d58:	29 d0                	sub    %edx,%eax
c0107d5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c0107d5d:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0107d64:	76 11                	jbe    c0107d77 <mm_map+0x5e>
c0107d66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d69:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107d6c:	73 09                	jae    c0107d77 <mm_map+0x5e>
c0107d6e:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0107d75:	76 0a                	jbe    c0107d81 <mm_map+0x68>
        return -E_INVAL;
c0107d77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0107d7c:	e9 9e 00 00 00       	jmp    c0107e1f <mm_map+0x106>
    }

    assert(mm != NULL);
c0107d81:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107d85:	75 19                	jne    c0107da0 <mm_map+0x87>
c0107d87:	68 cb d0 10 c0       	push   $0xc010d0cb
c0107d8c:	68 3b d0 10 c0       	push   $0xc010d03b
c0107d91:	68 a8 00 00 00       	push   $0xa8
c0107d96:	68 50 d0 10 c0       	push   $0xc010d050
c0107d9b:	e8 e6 8f ff ff       	call   c0100d86 <__panic>

    int ret = -E_INVAL;
c0107da0:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c0107da7:	83 ec 08             	sub    $0x8,%esp
c0107daa:	ff 75 ec             	pushl  -0x14(%ebp)
c0107dad:	ff 75 08             	pushl  0x8(%ebp)
c0107db0:	e8 71 fc ff ff       	call   c0107a26 <find_vma>
c0107db5:	83 c4 10             	add    $0x10,%esp
c0107db8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107dbb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107dbf:	74 0b                	je     c0107dcc <mm_map+0xb3>
c0107dc1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107dc4:	8b 40 04             	mov    0x4(%eax),%eax
c0107dc7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107dca:	77 4c                	ja     c0107e18 <mm_map+0xff>
        goto out;
    }
    ret = -E_NO_MEM;
c0107dcc:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c0107dd3:	83 ec 04             	sub    $0x4,%esp
c0107dd6:	ff 75 14             	pushl  0x14(%ebp)
c0107dd9:	ff 75 e0             	pushl  -0x20(%ebp)
c0107ddc:	ff 75 ec             	pushl  -0x14(%ebp)
c0107ddf:	e8 06 fc ff ff       	call   c01079ea <vma_create>
c0107de4:	83 c4 10             	add    $0x10,%esp
c0107de7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107dea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107dee:	74 2b                	je     c0107e1b <mm_map+0x102>
        goto out;
    }
    insert_vma_struct(mm, vma);
c0107df0:	83 ec 08             	sub    $0x8,%esp
c0107df3:	ff 75 dc             	pushl  -0x24(%ebp)
c0107df6:	ff 75 08             	pushl  0x8(%ebp)
c0107df9:	e8 54 fd ff ff       	call   c0107b52 <insert_vma_struct>
c0107dfe:	83 c4 10             	add    $0x10,%esp
    if (vma_store != NULL) {
c0107e01:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107e05:	74 08                	je     c0107e0f <mm_map+0xf6>
        *vma_store = vma;
c0107e07:	8b 45 18             	mov    0x18(%ebp),%eax
c0107e0a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107e0d:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0107e0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107e16:	eb 04                	jmp    c0107e1c <mm_map+0x103>
        goto out;
c0107e18:	90                   	nop
c0107e19:	eb 01                	jmp    c0107e1c <mm_map+0x103>
        goto out;
c0107e1b:	90                   	nop

out:
    return ret;
c0107e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107e1f:	c9                   	leave  
c0107e20:	c3                   	ret    

c0107e21 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0107e21:	55                   	push   %ebp
c0107e22:	89 e5                	mov    %esp,%ebp
c0107e24:	53                   	push   %ebx
c0107e25:	83 ec 24             	sub    $0x24,%esp
    assert(to != NULL && from != NULL);
c0107e28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107e2c:	74 06                	je     c0107e34 <dup_mmap+0x13>
c0107e2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107e32:	75 19                	jne    c0107e4d <dup_mmap+0x2c>
c0107e34:	68 d6 d0 10 c0       	push   $0xc010d0d6
c0107e39:	68 3b d0 10 c0       	push   $0xc010d03b
c0107e3e:	68 c1 00 00 00       	push   $0xc1
c0107e43:	68 50 d0 10 c0       	push   $0xc010d050
c0107e48:	e8 39 8f ff ff       	call   c0100d86 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0107e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0107e59:	e9 86 00 00 00       	jmp    c0107ee4 <dup_mmap+0xc3>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c0107e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e61:	83 e8 10             	sub    $0x10,%eax
c0107e64:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0107e67:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e6a:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107e6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e70:	8b 50 08             	mov    0x8(%eax),%edx
c0107e73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e76:	8b 40 04             	mov    0x4(%eax),%eax
c0107e79:	83 ec 04             	sub    $0x4,%esp
c0107e7c:	51                   	push   %ecx
c0107e7d:	52                   	push   %edx
c0107e7e:	50                   	push   %eax
c0107e7f:	e8 66 fb ff ff       	call   c01079ea <vma_create>
c0107e84:	83 c4 10             	add    $0x10,%esp
c0107e87:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0107e8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107e8e:	75 07                	jne    c0107e97 <dup_mmap+0x76>
            return -E_NO_MEM;
c0107e90:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0107e95:	eb 6c                	jmp    c0107f03 <dup_mmap+0xe2>
        }

        insert_vma_struct(to, nvma);
c0107e97:	83 ec 08             	sub    $0x8,%esp
c0107e9a:	ff 75 e8             	pushl  -0x18(%ebp)
c0107e9d:	ff 75 08             	pushl  0x8(%ebp)
c0107ea0:	e8 ad fc ff ff       	call   c0107b52 <insert_vma_struct>
c0107ea5:	83 c4 10             	add    $0x10,%esp

        bool share = 0;
c0107ea8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c0107eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107eb2:	8b 58 08             	mov    0x8(%eax),%ebx
c0107eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107eb8:	8b 48 04             	mov    0x4(%eax),%ecx
c0107ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ebe:	8b 50 0c             	mov    0xc(%eax),%edx
c0107ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ec4:	8b 40 0c             	mov    0xc(%eax),%eax
c0107ec7:	83 ec 0c             	sub    $0xc,%esp
c0107eca:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107ecd:	53                   	push   %ebx
c0107ece:	51                   	push   %ecx
c0107ecf:	52                   	push   %edx
c0107ed0:	50                   	push   %eax
c0107ed1:	e8 c1 da ff ff       	call   c0105997 <copy_range>
c0107ed6:	83 c4 20             	add    $0x20,%esp
c0107ed9:	85 c0                	test   %eax,%eax
c0107edb:	74 07                	je     c0107ee4 <dup_mmap+0xc3>
            return -E_NO_MEM;
c0107edd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0107ee2:	eb 1f                	jmp    c0107f03 <dup_mmap+0xe2>
c0107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ee7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->prev;
c0107eea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107eed:	8b 00                	mov    (%eax),%eax
    while ((le = list_prev(le)) != list) {
c0107eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ef5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107ef8:	0f 85 60 ff ff ff    	jne    c0107e5e <dup_mmap+0x3d>
        }
    }
    return 0;
c0107efe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107f03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0107f06:	c9                   	leave  
c0107f07:	c3                   	ret    

c0107f08 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0107f08:	55                   	push   %ebp
c0107f09:	89 e5                	mov    %esp,%ebp
c0107f0b:	83 ec 28             	sub    $0x28,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0107f0e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107f12:	74 0f                	je     c0107f23 <exit_mmap+0x1b>
c0107f14:	ff 75 08             	pushl  0x8(%ebp)
c0107f17:	e8 15 fa ff ff       	call   c0107931 <mm_count>
c0107f1c:	83 c4 04             	add    $0x4,%esp
c0107f1f:	85 c0                	test   %eax,%eax
c0107f21:	74 19                	je     c0107f3c <exit_mmap+0x34>
c0107f23:	68 f4 d0 10 c0       	push   $0xc010d0f4
c0107f28:	68 3b d0 10 c0       	push   $0xc010d03b
c0107f2d:	68 d7 00 00 00       	push   $0xd7
c0107f32:	68 50 d0 10 c0       	push   $0xc010d050
c0107f37:	e8 4a 8e ff ff       	call   c0100d86 <__panic>
    pde_t *pgdir = mm->pgdir;
c0107f3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f3f:	8b 40 0c             	mov    0xc(%eax),%eax
c0107f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c0107f45:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f48:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107f4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107f4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0107f51:	eb 25                	jmp    c0107f78 <exit_mmap+0x70>
        struct vma_struct *vma = le2vma(le, list_link);
c0107f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f56:	83 e8 10             	sub    $0x10,%eax
c0107f59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0107f5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f5f:	8b 50 08             	mov    0x8(%eax),%edx
c0107f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f65:	8b 40 04             	mov    0x4(%eax),%eax
c0107f68:	83 ec 04             	sub    $0x4,%esp
c0107f6b:	52                   	push   %edx
c0107f6c:	50                   	push   %eax
c0107f6d:	ff 75 f0             	pushl  -0x10(%ebp)
c0107f70:	e8 5b d8 ff ff       	call   c01057d0 <unmap_range>
c0107f75:	83 c4 10             	add    $0x10,%esp
c0107f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107f7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107f81:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0107f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107f8d:	75 c4                	jne    c0107f53 <exit_mmap+0x4b>
    }
    while ((le = list_next(le)) != list) {
c0107f8f:	eb 25                	jmp    c0107fb6 <exit_mmap+0xae>
        struct vma_struct *vma = le2vma(le, list_link);
c0107f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f94:	83 e8 10             	sub    $0x10,%eax
c0107f97:	89 45 e8             	mov    %eax,-0x18(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0107f9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f9d:	8b 50 08             	mov    0x8(%eax),%edx
c0107fa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fa3:	8b 40 04             	mov    0x4(%eax),%eax
c0107fa6:	83 ec 04             	sub    $0x4,%esp
c0107fa9:	52                   	push   %edx
c0107faa:	50                   	push   %eax
c0107fab:	ff 75 f0             	pushl  -0x10(%ebp)
c0107fae:	e8 f0 d8 ff ff       	call   c01058a3 <exit_range>
c0107fb3:	83 c4 10             	add    $0x10,%esp
c0107fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fb9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107fbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107fbf:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c0107fc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fc8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107fcb:	75 c4                	jne    c0107f91 <exit_mmap+0x89>
    }
}
c0107fcd:	90                   	nop
c0107fce:	90                   	nop
c0107fcf:	c9                   	leave  
c0107fd0:	c3                   	ret    

c0107fd1 <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c0107fd1:	55                   	push   %ebp
c0107fd2:	89 e5                	mov    %esp,%ebp
c0107fd4:	83 ec 08             	sub    $0x8,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0107fd7:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fda:	ff 75 18             	pushl  0x18(%ebp)
c0107fdd:	ff 75 14             	pushl  0x14(%ebp)
c0107fe0:	50                   	push   %eax
c0107fe1:	ff 75 08             	pushl  0x8(%ebp)
c0107fe4:	e8 8a 08 00 00       	call   c0108873 <user_mem_check>
c0107fe9:	83 c4 10             	add    $0x10,%esp
c0107fec:	85 c0                	test   %eax,%eax
c0107fee:	75 07                	jne    c0107ff7 <copy_from_user+0x26>
        return 0;
c0107ff0:	b8 00 00 00 00       	mov    $0x0,%eax
c0107ff5:	eb 19                	jmp    c0108010 <copy_from_user+0x3f>
    }
    memcpy(dst, src, len);
c0107ff7:	83 ec 04             	sub    $0x4,%esp
c0107ffa:	ff 75 14             	pushl  0x14(%ebp)
c0107ffd:	ff 75 10             	pushl  0x10(%ebp)
c0108000:	ff 75 0c             	pushl  0xc(%ebp)
c0108003:	e8 bd 33 00 00       	call   c010b3c5 <memcpy>
c0108008:	83 c4 10             	add    $0x10,%esp
    return 1;
c010800b:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0108010:	c9                   	leave  
c0108011:	c3                   	ret    

c0108012 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0108012:	55                   	push   %ebp
c0108013:	89 e5                	mov    %esp,%ebp
c0108015:	83 ec 08             	sub    $0x8,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0108018:	8b 45 0c             	mov    0xc(%ebp),%eax
c010801b:	6a 01                	push   $0x1
c010801d:	ff 75 14             	pushl  0x14(%ebp)
c0108020:	50                   	push   %eax
c0108021:	ff 75 08             	pushl  0x8(%ebp)
c0108024:	e8 4a 08 00 00       	call   c0108873 <user_mem_check>
c0108029:	83 c4 10             	add    $0x10,%esp
c010802c:	85 c0                	test   %eax,%eax
c010802e:	75 07                	jne    c0108037 <copy_to_user+0x25>
        return 0;
c0108030:	b8 00 00 00 00       	mov    $0x0,%eax
c0108035:	eb 19                	jmp    c0108050 <copy_to_user+0x3e>
    }
    memcpy(dst, src, len);
c0108037:	83 ec 04             	sub    $0x4,%esp
c010803a:	ff 75 14             	pushl  0x14(%ebp)
c010803d:	ff 75 10             	pushl  0x10(%ebp)
c0108040:	ff 75 0c             	pushl  0xc(%ebp)
c0108043:	e8 7d 33 00 00       	call   c010b3c5 <memcpy>
c0108048:	83 c4 10             	add    $0x10,%esp
    return 1;
c010804b:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0108050:	c9                   	leave  
c0108051:	c3                   	ret    

c0108052 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0108052:	55                   	push   %ebp
c0108053:	89 e5                	mov    %esp,%ebp
c0108055:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0108058:	e8 03 00 00 00       	call   c0108060 <check_vmm>
}
c010805d:	90                   	nop
c010805e:	c9                   	leave  
c010805f:	c3                   	ret    

c0108060 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0108060:	55                   	push   %ebp
c0108061:	89 e5                	mov    %esp,%ebp
c0108063:	83 ec 18             	sub    $0x18,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108066:	e8 d9 cf ff ff       	call   c0105044 <nr_free_pages>
c010806b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    check_vma_struct();
c010806e:	e8 18 00 00 00       	call   c010808b <check_vma_struct>
    check_pgfault();
c0108073:	e8 10 04 00 00       	call   c0108488 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0108078:	83 ec 0c             	sub    $0xc,%esp
c010807b:	68 14 d1 10 c0       	push   $0xc010d114
c0108080:	e8 c3 82 ff ff       	call   c0100348 <cprintf>
c0108085:	83 c4 10             	add    $0x10,%esp
}
c0108088:	90                   	nop
c0108089:	c9                   	leave  
c010808a:	c3                   	ret    

c010808b <check_vma_struct>:

static void
check_vma_struct(void) {
c010808b:	55                   	push   %ebp
c010808c:	89 e5                	mov    %esp,%ebp
c010808e:	83 ec 58             	sub    $0x58,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108091:	e8 ae cf ff ff       	call   c0105044 <nr_free_pages>
c0108096:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0108099:	e8 ad f8 ff ff       	call   c010794b <mm_create>
c010809e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01080a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01080a5:	75 19                	jne    c01080c0 <check_vma_struct+0x35>
c01080a7:	68 cb d0 10 c0       	push   $0xc010d0cb
c01080ac:	68 3b d0 10 c0       	push   $0xc010d03b
c01080b1:	68 0d 01 00 00       	push   $0x10d
c01080b6:	68 50 d0 10 c0       	push   $0xc010d050
c01080bb:	e8 c6 8c ff ff       	call   c0100d86 <__panic>

    int step1 = 10, step2 = step1 * 10;
c01080c0:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c01080c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01080ca:	89 d0                	mov    %edx,%eax
c01080cc:	c1 e0 02             	shl    $0x2,%eax
c01080cf:	01 d0                	add    %edx,%eax
c01080d1:	01 c0                	add    %eax,%eax
c01080d3:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i--) {
c01080d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01080d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080dc:	eb 5f                	jmp    c010813d <check_vma_struct+0xb2>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01080de:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080e1:	89 d0                	mov    %edx,%eax
c01080e3:	c1 e0 02             	shl    $0x2,%eax
c01080e6:	01 d0                	add    %edx,%eax
c01080e8:	83 c0 02             	add    $0x2,%eax
c01080eb:	89 c1                	mov    %eax,%ecx
c01080ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080f0:	89 d0                	mov    %edx,%eax
c01080f2:	c1 e0 02             	shl    $0x2,%eax
c01080f5:	01 d0                	add    %edx,%eax
c01080f7:	83 ec 04             	sub    $0x4,%esp
c01080fa:	6a 00                	push   $0x0
c01080fc:	51                   	push   %ecx
c01080fd:	50                   	push   %eax
c01080fe:	e8 e7 f8 ff ff       	call   c01079ea <vma_create>
c0108103:	83 c4 10             	add    $0x10,%esp
c0108106:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0108109:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010810d:	75 19                	jne    c0108128 <check_vma_struct+0x9d>
c010810f:	68 2c d1 10 c0       	push   $0xc010d12c
c0108114:	68 3b d0 10 c0       	push   $0xc010d03b
c0108119:	68 14 01 00 00       	push   $0x114
c010811e:	68 50 d0 10 c0       	push   $0xc010d050
c0108123:	e8 5e 8c ff ff       	call   c0100d86 <__panic>
        insert_vma_struct(mm, vma);
c0108128:	83 ec 08             	sub    $0x8,%esp
c010812b:	ff 75 bc             	pushl  -0x44(%ebp)
c010812e:	ff 75 e8             	pushl  -0x18(%ebp)
c0108131:	e8 1c fa ff ff       	call   c0107b52 <insert_vma_struct>
c0108136:	83 c4 10             	add    $0x10,%esp
    for (i = step1; i >= 1; i--) {
c0108139:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010813d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108141:	7f 9b                	jg     c01080de <check_vma_struct+0x53>
    }

    for (i = step1 + 1; i <= step2; i++) {
c0108143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108146:	83 c0 01             	add    $0x1,%eax
c0108149:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010814c:	eb 5f                	jmp    c01081ad <check_vma_struct+0x122>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010814e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108151:	89 d0                	mov    %edx,%eax
c0108153:	c1 e0 02             	shl    $0x2,%eax
c0108156:	01 d0                	add    %edx,%eax
c0108158:	83 c0 02             	add    $0x2,%eax
c010815b:	89 c1                	mov    %eax,%ecx
c010815d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108160:	89 d0                	mov    %edx,%eax
c0108162:	c1 e0 02             	shl    $0x2,%eax
c0108165:	01 d0                	add    %edx,%eax
c0108167:	83 ec 04             	sub    $0x4,%esp
c010816a:	6a 00                	push   $0x0
c010816c:	51                   	push   %ecx
c010816d:	50                   	push   %eax
c010816e:	e8 77 f8 ff ff       	call   c01079ea <vma_create>
c0108173:	83 c4 10             	add    $0x10,%esp
c0108176:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0108179:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010817d:	75 19                	jne    c0108198 <check_vma_struct+0x10d>
c010817f:	68 2c d1 10 c0       	push   $0xc010d12c
c0108184:	68 3b d0 10 c0       	push   $0xc010d03b
c0108189:	68 1a 01 00 00       	push   $0x11a
c010818e:	68 50 d0 10 c0       	push   $0xc010d050
c0108193:	e8 ee 8b ff ff       	call   c0100d86 <__panic>
        insert_vma_struct(mm, vma);
c0108198:	83 ec 08             	sub    $0x8,%esp
c010819b:	ff 75 c0             	pushl  -0x40(%ebp)
c010819e:	ff 75 e8             	pushl  -0x18(%ebp)
c01081a1:	e8 ac f9 ff ff       	call   c0107b52 <insert_vma_struct>
c01081a6:	83 c4 10             	add    $0x10,%esp
    for (i = step1 + 1; i <= step2; i++) {
c01081a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01081ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081b0:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01081b3:	7e 99                	jle    c010814e <check_vma_struct+0xc3>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01081b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081b8:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01081bb:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01081be:	8b 40 04             	mov    0x4(%eax),%eax
c01081c1:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i++) {
c01081c4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c01081cb:	e9 81 00 00 00       	jmp    c0108251 <check_vma_struct+0x1c6>
        assert(le != &(mm->mmap_list));
c01081d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081d3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01081d6:	75 19                	jne    c01081f1 <check_vma_struct+0x166>
c01081d8:	68 38 d1 10 c0       	push   $0xc010d138
c01081dd:	68 3b d0 10 c0       	push   $0xc010d03b
c01081e2:	68 21 01 00 00       	push   $0x121
c01081e7:	68 50 d0 10 c0       	push   $0xc010d050
c01081ec:	e8 95 8b ff ff       	call   c0100d86 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01081f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081f4:	83 e8 10             	sub    $0x10,%eax
c01081f7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01081fa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01081fd:	8b 48 04             	mov    0x4(%eax),%ecx
c0108200:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108203:	89 d0                	mov    %edx,%eax
c0108205:	c1 e0 02             	shl    $0x2,%eax
c0108208:	01 d0                	add    %edx,%eax
c010820a:	39 c1                	cmp    %eax,%ecx
c010820c:	75 17                	jne    c0108225 <check_vma_struct+0x19a>
c010820e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108211:	8b 48 08             	mov    0x8(%eax),%ecx
c0108214:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108217:	89 d0                	mov    %edx,%eax
c0108219:	c1 e0 02             	shl    $0x2,%eax
c010821c:	01 d0                	add    %edx,%eax
c010821e:	83 c0 02             	add    $0x2,%eax
c0108221:	39 c1                	cmp    %eax,%ecx
c0108223:	74 19                	je     c010823e <check_vma_struct+0x1b3>
c0108225:	68 50 d1 10 c0       	push   $0xc010d150
c010822a:	68 3b d0 10 c0       	push   $0xc010d03b
c010822f:	68 23 01 00 00       	push   $0x123
c0108234:	68 50 d0 10 c0       	push   $0xc010d050
c0108239:	e8 48 8b ff ff       	call   c0100d86 <__panic>
c010823e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108241:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0108244:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108247:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010824a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i++) {
c010824d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108251:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108254:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108257:	0f 8e 73 ff ff ff    	jle    c01081d0 <check_vma_struct+0x145>
    }

    for (i = 5; i <= 5 * step2; i += 5) {
c010825d:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0108264:	e9 80 01 00 00       	jmp    c01083e9 <check_vma_struct+0x35e>
        struct vma_struct *vma1 = find_vma(mm, i);
c0108269:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010826c:	83 ec 08             	sub    $0x8,%esp
c010826f:	50                   	push   %eax
c0108270:	ff 75 e8             	pushl  -0x18(%ebp)
c0108273:	e8 ae f7 ff ff       	call   c0107a26 <find_vma>
c0108278:	83 c4 10             	add    $0x10,%esp
c010827b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c010827e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0108282:	75 19                	jne    c010829d <check_vma_struct+0x212>
c0108284:	68 85 d1 10 c0       	push   $0xc010d185
c0108289:	68 3b d0 10 c0       	push   $0xc010d03b
c010828e:	68 29 01 00 00       	push   $0x129
c0108293:	68 50 d0 10 c0       	push   $0xc010d050
c0108298:	e8 e9 8a ff ff       	call   c0100d86 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
c010829d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082a0:	83 c0 01             	add    $0x1,%eax
c01082a3:	83 ec 08             	sub    $0x8,%esp
c01082a6:	50                   	push   %eax
c01082a7:	ff 75 e8             	pushl  -0x18(%ebp)
c01082aa:	e8 77 f7 ff ff       	call   c0107a26 <find_vma>
c01082af:	83 c4 10             	add    $0x10,%esp
c01082b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c01082b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01082b9:	75 19                	jne    c01082d4 <check_vma_struct+0x249>
c01082bb:	68 92 d1 10 c0       	push   $0xc010d192
c01082c0:	68 3b d0 10 c0       	push   $0xc010d03b
c01082c5:	68 2b 01 00 00       	push   $0x12b
c01082ca:	68 50 d0 10 c0       	push   $0xc010d050
c01082cf:	e8 b2 8a ff ff       	call   c0100d86 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
c01082d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082d7:	83 c0 02             	add    $0x2,%eax
c01082da:	83 ec 08             	sub    $0x8,%esp
c01082dd:	50                   	push   %eax
c01082de:	ff 75 e8             	pushl  -0x18(%ebp)
c01082e1:	e8 40 f7 ff ff       	call   c0107a26 <find_vma>
c01082e6:	83 c4 10             	add    $0x10,%esp
c01082e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c01082ec:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01082f0:	74 19                	je     c010830b <check_vma_struct+0x280>
c01082f2:	68 9f d1 10 c0       	push   $0xc010d19f
c01082f7:	68 3b d0 10 c0       	push   $0xc010d03b
c01082fc:	68 2d 01 00 00       	push   $0x12d
c0108301:	68 50 d0 10 c0       	push   $0xc010d050
c0108306:	e8 7b 8a ff ff       	call   c0100d86 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
c010830b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010830e:	83 c0 03             	add    $0x3,%eax
c0108311:	83 ec 08             	sub    $0x8,%esp
c0108314:	50                   	push   %eax
c0108315:	ff 75 e8             	pushl  -0x18(%ebp)
c0108318:	e8 09 f7 ff ff       	call   c0107a26 <find_vma>
c010831d:	83 c4 10             	add    $0x10,%esp
c0108320:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0108323:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108327:	74 19                	je     c0108342 <check_vma_struct+0x2b7>
c0108329:	68 ac d1 10 c0       	push   $0xc010d1ac
c010832e:	68 3b d0 10 c0       	push   $0xc010d03b
c0108333:	68 2f 01 00 00       	push   $0x12f
c0108338:	68 50 d0 10 c0       	push   $0xc010d050
c010833d:	e8 44 8a ff ff       	call   c0100d86 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
c0108342:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108345:	83 c0 04             	add    $0x4,%eax
c0108348:	83 ec 08             	sub    $0x8,%esp
c010834b:	50                   	push   %eax
c010834c:	ff 75 e8             	pushl  -0x18(%ebp)
c010834f:	e8 d2 f6 ff ff       	call   c0107a26 <find_vma>
c0108354:	83 c4 10             	add    $0x10,%esp
c0108357:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c010835a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010835e:	74 19                	je     c0108379 <check_vma_struct+0x2ee>
c0108360:	68 b9 d1 10 c0       	push   $0xc010d1b9
c0108365:	68 3b d0 10 c0       	push   $0xc010d03b
c010836a:	68 31 01 00 00       	push   $0x131
c010836f:	68 50 d0 10 c0       	push   $0xc010d050
c0108374:	e8 0d 8a ff ff       	call   c0100d86 <__panic>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
c0108379:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010837c:	8b 50 04             	mov    0x4(%eax),%edx
c010837f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108382:	39 c2                	cmp    %eax,%edx
c0108384:	75 10                	jne    c0108396 <check_vma_struct+0x30b>
c0108386:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108389:	8b 40 08             	mov    0x8(%eax),%eax
c010838c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010838f:	83 c2 02             	add    $0x2,%edx
c0108392:	39 d0                	cmp    %edx,%eax
c0108394:	74 19                	je     c01083af <check_vma_struct+0x324>
c0108396:	68 c8 d1 10 c0       	push   $0xc010d1c8
c010839b:	68 3b d0 10 c0       	push   $0xc010d03b
c01083a0:	68 33 01 00 00       	push   $0x133
c01083a5:	68 50 d0 10 c0       	push   $0xc010d050
c01083aa:	e8 d7 89 ff ff       	call   c0100d86 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
c01083af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01083b2:	8b 50 04             	mov    0x4(%eax),%edx
c01083b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083b8:	39 c2                	cmp    %eax,%edx
c01083ba:	75 10                	jne    c01083cc <check_vma_struct+0x341>
c01083bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01083bf:	8b 40 08             	mov    0x8(%eax),%eax
c01083c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01083c5:	83 c2 02             	add    $0x2,%edx
c01083c8:	39 d0                	cmp    %edx,%eax
c01083ca:	74 19                	je     c01083e5 <check_vma_struct+0x35a>
c01083cc:	68 f8 d1 10 c0       	push   $0xc010d1f8
c01083d1:	68 3b d0 10 c0       	push   $0xc010d03b
c01083d6:	68 34 01 00 00       	push   $0x134
c01083db:	68 50 d0 10 c0       	push   $0xc010d050
c01083e0:	e8 a1 89 ff ff       	call   c0100d86 <__panic>
    for (i = 5; i <= 5 * step2; i += 5) {
c01083e5:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c01083e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01083ec:	89 d0                	mov    %edx,%eax
c01083ee:	c1 e0 02             	shl    $0x2,%eax
c01083f1:	01 d0                	add    %edx,%eax
c01083f3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01083f6:	0f 8e 6d fe ff ff    	jle    c0108269 <check_vma_struct+0x1de>
    }

    for (i = 4; i >= 0; i--) {
c01083fc:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108403:	eb 5c                	jmp    c0108461 <check_vma_struct+0x3d6>
        struct vma_struct *vma_below_5 = find_vma(mm, i);
c0108405:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108408:	83 ec 08             	sub    $0x8,%esp
c010840b:	50                   	push   %eax
c010840c:	ff 75 e8             	pushl  -0x18(%ebp)
c010840f:	e8 12 f6 ff ff       	call   c0107a26 <find_vma>
c0108414:	83 c4 10             	add    $0x10,%esp
c0108417:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL) {
c010841a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010841e:	74 1e                	je     c010843e <check_vma_struct+0x3b3>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
c0108420:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108423:	8b 50 08             	mov    0x8(%eax),%edx
c0108426:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108429:	8b 40 04             	mov    0x4(%eax),%eax
c010842c:	52                   	push   %edx
c010842d:	50                   	push   %eax
c010842e:	ff 75 f4             	pushl  -0xc(%ebp)
c0108431:	68 28 d2 10 c0       	push   $0xc010d228
c0108436:	e8 0d 7f ff ff       	call   c0100348 <cprintf>
c010843b:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c010843e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108442:	74 19                	je     c010845d <check_vma_struct+0x3d2>
c0108444:	68 4d d2 10 c0       	push   $0xc010d24d
c0108449:	68 3b d0 10 c0       	push   $0xc010d03b
c010844e:	68 3c 01 00 00       	push   $0x13c
c0108453:	68 50 d0 10 c0       	push   $0xc010d050
c0108458:	e8 29 89 ff ff       	call   c0100d86 <__panic>
    for (i = 4; i >= 0; i--) {
c010845d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108461:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108465:	79 9e                	jns    c0108405 <check_vma_struct+0x37a>
    }

    mm_destroy(mm);
c0108467:	83 ec 0c             	sub    $0xc,%esp
c010846a:	ff 75 e8             	pushl  -0x18(%ebp)
c010846d:	e8 06 f8 ff ff       	call   c0107c78 <mm_destroy>
c0108472:	83 c4 10             	add    $0x10,%esp

    cprintf("check_vma_struct() succeeded!\n");
c0108475:	83 ec 0c             	sub    $0xc,%esp
c0108478:	68 64 d2 10 c0       	push   $0xc010d264
c010847d:	e8 c6 7e ff ff       	call   c0100348 <cprintf>
c0108482:	83 c4 10             	add    $0x10,%esp
}
c0108485:	90                   	nop
c0108486:	c9                   	leave  
c0108487:	c3                   	ret    

c0108488 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108488:	55                   	push   %ebp
c0108489:	89 e5                	mov    %esp,%ebp
c010848b:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010848e:	e8 b1 cb ff ff       	call   c0105044 <nr_free_pages>
c0108493:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108496:	e8 b0 f4 ff ff       	call   c010794b <mm_create>
c010849b:	a3 0c 41 1a c0       	mov    %eax,0xc01a410c
    assert(check_mm_struct != NULL);
c01084a0:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c01084a5:	85 c0                	test   %eax,%eax
c01084a7:	75 19                	jne    c01084c2 <check_pgfault+0x3a>
c01084a9:	68 83 d2 10 c0       	push   $0xc010d283
c01084ae:	68 3b d0 10 c0       	push   $0xc010d03b
c01084b3:	68 4c 01 00 00       	push   $0x14c
c01084b8:	68 50 d0 10 c0       	push   $0xc010d050
c01084bd:	e8 c4 88 ff ff       	call   c0100d86 <__panic>

    struct mm_struct *mm = check_mm_struct;
c01084c2:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c01084c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c01084ca:	8b 15 00 fa 12 c0    	mov    0xc012fa00,%edx
c01084d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084d3:	89 50 0c             	mov    %edx,0xc(%eax)
c01084d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084d9:	8b 40 0c             	mov    0xc(%eax),%eax
c01084dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c01084df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01084e2:	8b 00                	mov    (%eax),%eax
c01084e4:	85 c0                	test   %eax,%eax
c01084e6:	74 19                	je     c0108501 <check_pgfault+0x79>
c01084e8:	68 9b d2 10 c0       	push   $0xc010d29b
c01084ed:	68 3b d0 10 c0       	push   $0xc010d03b
c01084f2:	68 50 01 00 00       	push   $0x150
c01084f7:	68 50 d0 10 c0       	push   $0xc010d050
c01084fc:	e8 85 88 ff ff       	call   c0100d86 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108501:	83 ec 04             	sub    $0x4,%esp
c0108504:	6a 02                	push   $0x2
c0108506:	68 00 00 40 00       	push   $0x400000
c010850b:	6a 00                	push   $0x0
c010850d:	e8 d8 f4 ff ff       	call   c01079ea <vma_create>
c0108512:	83 c4 10             	add    $0x10,%esp
c0108515:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108518:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010851c:	75 19                	jne    c0108537 <check_pgfault+0xaf>
c010851e:	68 2c d1 10 c0       	push   $0xc010d12c
c0108523:	68 3b d0 10 c0       	push   $0xc010d03b
c0108528:	68 53 01 00 00       	push   $0x153
c010852d:	68 50 d0 10 c0       	push   $0xc010d050
c0108532:	e8 4f 88 ff ff       	call   c0100d86 <__panic>

    insert_vma_struct(mm, vma);
c0108537:	83 ec 08             	sub    $0x8,%esp
c010853a:	ff 75 e0             	pushl  -0x20(%ebp)
c010853d:	ff 75 e8             	pushl  -0x18(%ebp)
c0108540:	e8 0d f6 ff ff       	call   c0107b52 <insert_vma_struct>
c0108545:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c0108548:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c010854f:	83 ec 08             	sub    $0x8,%esp
c0108552:	ff 75 dc             	pushl  -0x24(%ebp)
c0108555:	ff 75 e8             	pushl  -0x18(%ebp)
c0108558:	e8 c9 f4 ff ff       	call   c0107a26 <find_vma>
c010855d:	83 c4 10             	add    $0x10,%esp
c0108560:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108563:	74 19                	je     c010857e <check_pgfault+0xf6>
c0108565:	68 a9 d2 10 c0       	push   $0xc010d2a9
c010856a:	68 3b d0 10 c0       	push   $0xc010d03b
c010856f:	68 58 01 00 00       	push   $0x158
c0108574:	68 50 d0 10 c0       	push   $0xc010d050
c0108579:	e8 08 88 ff ff       	call   c0100d86 <__panic>

    int i, sum = 0;
c010857e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i++) {
c0108585:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010858c:	eb 17                	jmp    c01085a5 <check_pgfault+0x11d>
        *(char *)(addr + i) = i;
c010858e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108591:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108594:	01 d0                	add    %edx,%eax
c0108596:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108599:	88 10                	mov    %dl,(%eax)
        sum += i;
c010859b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010859e:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++) {
c01085a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01085a5:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01085a9:	7e e3                	jle    c010858e <check_pgfault+0x106>
    }
    for (i = 0; i < 100; i++) {
c01085ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01085b2:	eb 15                	jmp    c01085c9 <check_pgfault+0x141>
        sum -= *(char *)(addr + i);
c01085b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085ba:	01 d0                	add    %edx,%eax
c01085bc:	0f b6 00             	movzbl (%eax),%eax
c01085bf:	0f be c0             	movsbl %al,%eax
c01085c2:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++) {
c01085c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01085c9:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01085cd:	7e e5                	jle    c01085b4 <check_pgfault+0x12c>
    }
    assert(sum == 0);
c01085cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01085d3:	74 19                	je     c01085ee <check_pgfault+0x166>
c01085d5:	68 c3 d2 10 c0       	push   $0xc010d2c3
c01085da:	68 3b d0 10 c0       	push   $0xc010d03b
c01085df:	68 62 01 00 00       	push   $0x162
c01085e4:	68 50 d0 10 c0       	push   $0xc010d050
c01085e9:	e8 98 87 ff ff       	call   c0100d86 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01085ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01085f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01085f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01085fc:	83 ec 08             	sub    $0x8,%esp
c01085ff:	50                   	push   %eax
c0108600:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108603:	e8 6a d5 ff ff       	call   c0105b72 <page_remove>
c0108608:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(pgdir[0]));
c010860b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010860e:	8b 00                	mov    (%eax),%eax
c0108610:	83 ec 0c             	sub    $0xc,%esp
c0108613:	50                   	push   %eax
c0108614:	e8 ed f2 ff ff       	call   c0107906 <pde2page>
c0108619:	83 c4 10             	add    $0x10,%esp
c010861c:	83 ec 08             	sub    $0x8,%esp
c010861f:	6a 01                	push   $0x1
c0108621:	50                   	push   %eax
c0108622:	e8 e8 c9 ff ff       	call   c010500f <free_pages>
c0108627:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c010862a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010862d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108633:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108636:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c010863d:	83 ec 0c             	sub    $0xc,%esp
c0108640:	ff 75 e8             	pushl  -0x18(%ebp)
c0108643:	e8 30 f6 ff ff       	call   c0107c78 <mm_destroy>
c0108648:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c010864b:	c7 05 0c 41 1a c0 00 	movl   $0x0,0xc01a410c
c0108652:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108655:	e8 ea c9 ff ff       	call   c0105044 <nr_free_pages>
c010865a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010865d:	74 19                	je     c0108678 <check_pgfault+0x1f0>
c010865f:	68 cc d2 10 c0       	push   $0xc010d2cc
c0108664:	68 3b d0 10 c0       	push   $0xc010d03b
c0108669:	68 6c 01 00 00       	push   $0x16c
c010866e:	68 50 d0 10 c0       	push   $0xc010d050
c0108673:	e8 0e 87 ff ff       	call   c0100d86 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108678:	83 ec 0c             	sub    $0xc,%esp
c010867b:	68 f3 d2 10 c0       	push   $0xc010d2f3
c0108680:	e8 c3 7c ff ff       	call   c0100348 <cprintf>
c0108685:	83 c4 10             	add    $0x10,%esp
}
c0108688:	90                   	nop
c0108689:	c9                   	leave  
c010868a:	c3                   	ret    

c010868b <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c010868b:	55                   	push   %ebp
c010868c:	89 e5                	mov    %esp,%ebp
c010868e:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_INVAL;
c0108691:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108698:	ff 75 10             	pushl  0x10(%ebp)
c010869b:	ff 75 08             	pushl  0x8(%ebp)
c010869e:	e8 83 f3 ff ff       	call   c0107a26 <find_vma>
c01086a3:	83 c4 08             	add    $0x8,%esp
c01086a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pgfault_num++;
c01086a9:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01086ae:	83 c0 01             	add    $0x1,%eax
c01086b1:	a3 10 41 1a c0       	mov    %eax,0xc01a4110
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01086b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01086ba:	74 0b                	je     c01086c7 <do_pgfault+0x3c>
c01086bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086bf:	8b 40 04             	mov    0x4(%eax),%eax
c01086c2:	39 45 10             	cmp    %eax,0x10(%ebp)
c01086c5:	73 18                	jae    c01086df <do_pgfault+0x54>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01086c7:	83 ec 08             	sub    $0x8,%esp
c01086ca:	ff 75 10             	pushl  0x10(%ebp)
c01086cd:	68 10 d3 10 c0       	push   $0xc010d310
c01086d2:	e8 71 7c ff ff       	call   c0100348 <cprintf>
c01086d7:	83 c4 10             	add    $0x10,%esp
        goto failed;
c01086da:	e9 8f 01 00 00       	jmp    c010886e <do_pgfault+0x1e3>
    }
    //check the error_code
    switch (error_code & 3) {
c01086df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086e2:	83 e0 03             	and    $0x3,%eax
c01086e5:	85 c0                	test   %eax,%eax
c01086e7:	74 3c                	je     c0108725 <do_pgfault+0x9a>
c01086e9:	83 f8 01             	cmp    $0x1,%eax
c01086ec:	74 22                	je     c0108710 <do_pgfault+0x85>
        default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
        case 2: /* error code flag : (W/R=1, P=0): write, not present */
            if (!(vma->vm_flags & VM_WRITE)) {
c01086ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086f1:	8b 40 0c             	mov    0xc(%eax),%eax
c01086f4:	83 e0 02             	and    $0x2,%eax
c01086f7:	85 c0                	test   %eax,%eax
c01086f9:	75 4c                	jne    c0108747 <do_pgfault+0xbc>
                cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01086fb:	83 ec 0c             	sub    $0xc,%esp
c01086fe:	68 40 d3 10 c0       	push   $0xc010d340
c0108703:	e8 40 7c ff ff       	call   c0100348 <cprintf>
c0108708:	83 c4 10             	add    $0x10,%esp
                goto failed;
c010870b:	e9 5e 01 00 00       	jmp    c010886e <do_pgfault+0x1e3>
            }
            break;
        case 1: /* error code flag : (W/R=0, P=1): read, present */
            cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108710:	83 ec 0c             	sub    $0xc,%esp
c0108713:	68 a0 d3 10 c0       	push   $0xc010d3a0
c0108718:	e8 2b 7c ff ff       	call   c0100348 <cprintf>
c010871d:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0108720:	e9 49 01 00 00       	jmp    c010886e <do_pgfault+0x1e3>
        case 0: /* error code flag : (W/R=0, P=0): read, not present */
            if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108725:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108728:	8b 40 0c             	mov    0xc(%eax),%eax
c010872b:	83 e0 05             	and    $0x5,%eax
c010872e:	85 c0                	test   %eax,%eax
c0108730:	75 16                	jne    c0108748 <do_pgfault+0xbd>
                cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108732:	83 ec 0c             	sub    $0xc,%esp
c0108735:	68 d8 d3 10 c0       	push   $0xc010d3d8
c010873a:	e8 09 7c ff ff       	call   c0100348 <cprintf>
c010873f:	83 c4 10             	add    $0x10,%esp
                goto failed;
c0108742:	e9 27 01 00 00       	jmp    c010886e <do_pgfault+0x1e3>
            break;
c0108747:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108748:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c010874f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108752:	8b 40 0c             	mov    0xc(%eax),%eax
c0108755:	83 e0 02             	and    $0x2,%eax
c0108758:	85 c0                	test   %eax,%eax
c010875a:	74 04                	je     c0108760 <do_pgfault+0xd5>
        perm |= PTE_W;
c010875c:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108760:	8b 45 10             	mov    0x10(%ebp),%eax
c0108763:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108766:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108769:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010876e:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0108771:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep = NULL;
c0108778:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    *   mm->pgdir : the PDT of these vma
    *
    */
#if 1
    /*LAB3 EXERCISE 1: YOUR CODE*/
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
c010877f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108782:	8b 40 0c             	mov    0xc(%eax),%eax
c0108785:	83 ec 04             	sub    $0x4,%esp
c0108788:	6a 01                	push   $0x1
c010878a:	ff 75 10             	pushl  0x10(%ebp)
c010878d:	50                   	push   %eax
c010878e:	e8 5f ce ff ff       	call   c01055f2 <get_pte>
c0108793:	83 c4 10             	add    $0x10,%esp
c0108796:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (*ptep == 0) {
c0108799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010879c:	8b 00                	mov    (%eax),%eax
c010879e:	85 c0                	test   %eax,%eax
c01087a0:	75 35                	jne    c01087d7 <do_pgfault+0x14c>
        //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01087a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01087a5:	8b 40 0c             	mov    0xc(%eax),%eax
c01087a8:	83 ec 04             	sub    $0x4,%esp
c01087ab:	ff 75 f0             	pushl  -0x10(%ebp)
c01087ae:	ff 75 10             	pushl  0x10(%ebp)
c01087b1:	50                   	push   %eax
c01087b2:	e8 fe d4 ff ff       	call   c0105cb5 <pgdir_alloc_page>
c01087b7:	83 c4 10             	add    $0x10,%esp
c01087ba:	85 c0                	test   %eax,%eax
c01087bc:	0f 85 a5 00 00 00    	jne    c0108867 <do_pgfault+0x1dc>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01087c2:	83 ec 0c             	sub    $0xc,%esp
c01087c5:	68 3c d4 10 c0       	push   $0xc010d43c
c01087ca:	e8 79 7b ff ff       	call   c0100348 <cprintf>
c01087cf:	83 c4 10             	add    $0x10,%esp
            goto failed;
c01087d2:	e9 97 00 00 00       	jmp    c010886e <do_pgfault+0x1e3>
		     If the vma includes this addr is writable, then we can set the page writable by rewrite the *ptep.
		     This method could be used to implement the Copy on Write (COW) thchnology(a fast fork process method).
		  2) *ptep & PTE_P == 0 & but *ptep!=0, it means this pte is a  swap entry.
		     We should add the LAB3's results here.
     */
        if (swap_init_ok) {
c01087d7:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c01087dc:	85 c0                	test   %eax,%eax
c01087de:	74 6f                	je     c010884f <do_pgfault+0x1c4>
            struct Page *page = NULL;
c01087e0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            //(1）According to the mm AND addr, try to load the content of right disk page
            //    into the memory which page managed.
            //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            //(3) make the page swappable.
            //(4) [NOTICE]: you myabe need to update your lab3's implementation for LAB5's normal execution.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01087e7:	83 ec 04             	sub    $0x4,%esp
c01087ea:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01087ed:	50                   	push   %eax
c01087ee:	ff 75 10             	pushl  0x10(%ebp)
c01087f1:	ff 75 08             	pushl  0x8(%ebp)
c01087f4:	e8 16 e3 ff ff       	call   c0106b0f <swap_in>
c01087f9:	83 c4 10             	add    $0x10,%esp
c01087fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01087ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108803:	74 12                	je     c0108817 <do_pgfault+0x18c>
                cprintf("swap_in in do_pgfault failed\n");
c0108805:	83 ec 0c             	sub    $0xc,%esp
c0108808:	68 63 d4 10 c0       	push   $0xc010d463
c010880d:	e8 36 7b ff ff       	call   c0100348 <cprintf>
c0108812:	83 c4 10             	add    $0x10,%esp
c0108815:	eb 57                	jmp    c010886e <do_pgfault+0x1e3>
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
c0108817:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010881a:	8b 45 08             	mov    0x8(%ebp),%eax
c010881d:	8b 40 0c             	mov    0xc(%eax),%eax
c0108820:	ff 75 f0             	pushl  -0x10(%ebp)
c0108823:	ff 75 10             	pushl  0x10(%ebp)
c0108826:	52                   	push   %edx
c0108827:	50                   	push   %eax
c0108828:	e8 7e d3 ff ff       	call   c0105bab <page_insert>
c010882d:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm, addr, page, 1);
c0108830:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108833:	6a 01                	push   $0x1
c0108835:	50                   	push   %eax
c0108836:	ff 75 10             	pushl  0x10(%ebp)
c0108839:	ff 75 08             	pushl  0x8(%ebp)
c010883c:	e8 3e e1 ff ff       	call   c010697f <swap_map_swappable>
c0108841:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr = addr;
c0108844:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108847:	8b 55 10             	mov    0x10(%ebp),%edx
c010884a:	89 50 1c             	mov    %edx,0x1c(%eax)
c010884d:	eb 18                	jmp    c0108867 <do_pgfault+0x1dc>
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
c010884f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108852:	8b 00                	mov    (%eax),%eax
c0108854:	83 ec 08             	sub    $0x8,%esp
c0108857:	50                   	push   %eax
c0108858:	68 84 d4 10 c0       	push   $0xc010d484
c010885d:	e8 e6 7a ff ff       	call   c0100348 <cprintf>
c0108862:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0108865:	eb 07                	jmp    c010886e <do_pgfault+0x1e3>
        }
    }
#endif
    ret = 0;
c0108867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c010886e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108871:	c9                   	leave  
c0108872:	c3                   	ret    

c0108873 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0108873:	55                   	push   %ebp
c0108874:	89 e5                	mov    %esp,%ebp
c0108876:	83 ec 10             	sub    $0x10,%esp
    if (mm != NULL) {
c0108879:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010887d:	0f 84 dc 00 00 00    	je     c010895f <user_mem_check+0xec>
        if (!USER_ACCESS(addr, addr + len)) {
c0108883:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010888a:	76 1c                	jbe    c01088a8 <user_mem_check+0x35>
c010888c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010888f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108892:	01 d0                	add    %edx,%eax
c0108894:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0108897:	73 0f                	jae    c01088a8 <user_mem_check+0x35>
c0108899:	8b 55 0c             	mov    0xc(%ebp),%edx
c010889c:	8b 45 10             	mov    0x10(%ebp),%eax
c010889f:	01 d0                	add    %edx,%eax
c01088a1:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c01088a6:	76 0a                	jbe    c01088b2 <user_mem_check+0x3f>
            return 0;
c01088a8:	b8 00 00 00 00       	mov    $0x0,%eax
c01088ad:	e9 de 00 00 00       	jmp    c0108990 <user_mem_check+0x11d>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c01088b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01088b8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01088bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01088be:	01 d0                	add    %edx,%eax
c01088c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c01088c3:	e9 84 00 00 00       	jmp    c010894c <user_mem_check+0xd9>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c01088c8:	ff 75 fc             	pushl  -0x4(%ebp)
c01088cb:	ff 75 08             	pushl  0x8(%ebp)
c01088ce:	e8 53 f1 ff ff       	call   c0107a26 <find_vma>
c01088d3:	83 c4 08             	add    $0x8,%esp
c01088d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01088dd:	74 0b                	je     c01088ea <user_mem_check+0x77>
c01088df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088e2:	8b 40 04             	mov    0x4(%eax),%eax
c01088e5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01088e8:	73 0a                	jae    c01088f4 <user_mem_check+0x81>
                return 0;
c01088ea:	b8 00 00 00 00       	mov    $0x0,%eax
c01088ef:	e9 9c 00 00 00       	jmp    c0108990 <user_mem_check+0x11d>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c01088f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088f7:	8b 40 0c             	mov    0xc(%eax),%eax
c01088fa:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01088fe:	74 07                	je     c0108907 <user_mem_check+0x94>
c0108900:	ba 02 00 00 00       	mov    $0x2,%edx
c0108905:	eb 05                	jmp    c010890c <user_mem_check+0x99>
c0108907:	ba 01 00 00 00       	mov    $0x1,%edx
c010890c:	21 d0                	and    %edx,%eax
c010890e:	85 c0                	test   %eax,%eax
c0108910:	75 07                	jne    c0108919 <user_mem_check+0xa6>
                return 0;
c0108912:	b8 00 00 00 00       	mov    $0x0,%eax
c0108917:	eb 77                	jmp    c0108990 <user_mem_check+0x11d>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c0108919:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010891d:	74 24                	je     c0108943 <user_mem_check+0xd0>
c010891f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108922:	8b 40 0c             	mov    0xc(%eax),%eax
c0108925:	83 e0 08             	and    $0x8,%eax
c0108928:	85 c0                	test   %eax,%eax
c010892a:	74 17                	je     c0108943 <user_mem_check+0xd0>
                if (start < vma->vm_start + PGSIZE) {  //check stack start & size
c010892c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010892f:	8b 40 04             	mov    0x4(%eax),%eax
c0108932:	05 00 10 00 00       	add    $0x1000,%eax
c0108937:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010893a:	73 07                	jae    c0108943 <user_mem_check+0xd0>
                    return 0;
c010893c:	b8 00 00 00 00       	mov    $0x0,%eax
c0108941:	eb 4d                	jmp    c0108990 <user_mem_check+0x11d>
                }
            }
            start = vma->vm_end;
c0108943:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108946:	8b 40 08             	mov    0x8(%eax),%eax
c0108949:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < end) {
c010894c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010894f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0108952:	0f 82 70 ff ff ff    	jb     c01088c8 <user_mem_check+0x55>
        }
        return 1;
c0108958:	b8 01 00 00 00       	mov    $0x1,%eax
c010895d:	eb 31                	jmp    c0108990 <user_mem_check+0x11d>
    }
    return KERN_ACCESS(addr, addr + len);
c010895f:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c0108966:	76 23                	jbe    c010898b <user_mem_check+0x118>
c0108968:	8b 55 0c             	mov    0xc(%ebp),%edx
c010896b:	8b 45 10             	mov    0x10(%ebp),%eax
c010896e:	01 d0                	add    %edx,%eax
c0108970:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0108973:	73 16                	jae    c010898b <user_mem_check+0x118>
c0108975:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108978:	8b 45 10             	mov    0x10(%ebp),%eax
c010897b:	01 d0                	add    %edx,%eax
c010897d:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c0108982:	77 07                	ja     c010898b <user_mem_check+0x118>
c0108984:	b8 01 00 00 00       	mov    $0x1,%eax
c0108989:	eb 05                	jmp    c0108990 <user_mem_check+0x11d>
c010898b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108990:	c9                   	leave  
c0108991:	c3                   	ret    

c0108992 <page2ppn>:
page2ppn(struct Page *page) {
c0108992:	55                   	push   %ebp
c0108993:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108995:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c010899b:	8b 45 08             	mov    0x8(%ebp),%eax
c010899e:	29 d0                	sub    %edx,%eax
c01089a0:	c1 f8 05             	sar    $0x5,%eax
}
c01089a3:	5d                   	pop    %ebp
c01089a4:	c3                   	ret    

c01089a5 <page2pa>:
page2pa(struct Page *page) {
c01089a5:	55                   	push   %ebp
c01089a6:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01089a8:	ff 75 08             	pushl  0x8(%ebp)
c01089ab:	e8 e2 ff ff ff       	call   c0108992 <page2ppn>
c01089b0:	83 c4 04             	add    $0x4,%esp
c01089b3:	c1 e0 0c             	shl    $0xc,%eax
}
c01089b6:	c9                   	leave  
c01089b7:	c3                   	ret    

c01089b8 <page2kva>:
page2kva(struct Page *page) {
c01089b8:	55                   	push   %ebp
c01089b9:	89 e5                	mov    %esp,%ebp
c01089bb:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c01089be:	ff 75 08             	pushl  0x8(%ebp)
c01089c1:	e8 df ff ff ff       	call   c01089a5 <page2pa>
c01089c6:	83 c4 04             	add    $0x4,%esp
c01089c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01089cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089cf:	c1 e8 0c             	shr    $0xc,%eax
c01089d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089d5:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01089da:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01089dd:	72 14                	jb     c01089f3 <page2kva+0x3b>
c01089df:	ff 75 f4             	pushl  -0xc(%ebp)
c01089e2:	68 ac d4 10 c0       	push   $0xc010d4ac
c01089e7:	6a 65                	push   $0x65
c01089e9:	68 cf d4 10 c0       	push   $0xc010d4cf
c01089ee:	e8 93 83 ff ff       	call   c0100d86 <__panic>
c01089f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01089fb:	c9                   	leave  
c01089fc:	c3                   	ret    

c01089fd <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01089fd:	55                   	push   %ebp
c01089fe:	89 e5                	mov    %esp,%ebp
c0108a00:	83 ec 08             	sub    $0x8,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0108a03:	83 ec 0c             	sub    $0xc,%esp
c0108a06:	6a 01                	push   $0x1
c0108a08:	e8 be 90 ff ff       	call   c0101acb <ide_device_valid>
c0108a0d:	83 c4 10             	add    $0x10,%esp
c0108a10:	85 c0                	test   %eax,%eax
c0108a12:	75 14                	jne    c0108a28 <swapfs_init+0x2b>
        panic("swap fs isn't available.\n");
c0108a14:	83 ec 04             	sub    $0x4,%esp
c0108a17:	68 dd d4 10 c0       	push   $0xc010d4dd
c0108a1c:	6a 0d                	push   $0xd
c0108a1e:	68 f7 d4 10 c0       	push   $0xc010d4f7
c0108a23:	e8 5e 83 ff ff       	call   c0100d86 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0108a28:	83 ec 0c             	sub    $0xc,%esp
c0108a2b:	6a 01                	push   $0x1
c0108a2d:	e8 ce 90 ff ff       	call   c0101b00 <ide_device_size>
c0108a32:	83 c4 10             	add    $0x10,%esp
c0108a35:	c1 e8 03             	shr    $0x3,%eax
c0108a38:	a3 40 40 1a c0       	mov    %eax,0xc01a4040
}
c0108a3d:	90                   	nop
c0108a3e:	c9                   	leave  
c0108a3f:	c3                   	ret    

c0108a40 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0108a40:	55                   	push   %ebp
c0108a41:	89 e5                	mov    %esp,%ebp
c0108a43:	83 ec 18             	sub    $0x18,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108a46:	83 ec 0c             	sub    $0xc,%esp
c0108a49:	ff 75 0c             	pushl  0xc(%ebp)
c0108a4c:	e8 67 ff ff ff       	call   c01089b8 <page2kva>
c0108a51:	83 c4 10             	add    $0x10,%esp
c0108a54:	8b 55 08             	mov    0x8(%ebp),%edx
c0108a57:	c1 ea 08             	shr    $0x8,%edx
c0108a5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108a5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108a61:	74 0b                	je     c0108a6e <swapfs_read+0x2e>
c0108a63:	8b 15 40 40 1a c0    	mov    0xc01a4040,%edx
c0108a69:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108a6c:	72 14                	jb     c0108a82 <swapfs_read+0x42>
c0108a6e:	ff 75 08             	pushl  0x8(%ebp)
c0108a71:	68 08 d5 10 c0       	push   $0xc010d508
c0108a76:	6a 14                	push   $0x14
c0108a78:	68 f7 d4 10 c0       	push   $0xc010d4f7
c0108a7d:	e8 04 83 ff ff       	call   c0100d86 <__panic>
c0108a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a85:	c1 e2 03             	shl    $0x3,%edx
c0108a88:	6a 08                	push   $0x8
c0108a8a:	50                   	push   %eax
c0108a8b:	52                   	push   %edx
c0108a8c:	6a 01                	push   $0x1
c0108a8e:	e8 a2 90 ff ff       	call   c0101b35 <ide_read_secs>
c0108a93:	83 c4 10             	add    $0x10,%esp
}
c0108a96:	c9                   	leave  
c0108a97:	c3                   	ret    

c0108a98 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0108a98:	55                   	push   %ebp
c0108a99:	89 e5                	mov    %esp,%ebp
c0108a9b:	83 ec 18             	sub    $0x18,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108a9e:	83 ec 0c             	sub    $0xc,%esp
c0108aa1:	ff 75 0c             	pushl  0xc(%ebp)
c0108aa4:	e8 0f ff ff ff       	call   c01089b8 <page2kva>
c0108aa9:	83 c4 10             	add    $0x10,%esp
c0108aac:	8b 55 08             	mov    0x8(%ebp),%edx
c0108aaf:	c1 ea 08             	shr    $0x8,%edx
c0108ab2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108ab5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108ab9:	74 0b                	je     c0108ac6 <swapfs_write+0x2e>
c0108abb:	8b 15 40 40 1a c0    	mov    0xc01a4040,%edx
c0108ac1:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108ac4:	72 14                	jb     c0108ada <swapfs_write+0x42>
c0108ac6:	ff 75 08             	pushl  0x8(%ebp)
c0108ac9:	68 08 d5 10 c0       	push   $0xc010d508
c0108ace:	6a 19                	push   $0x19
c0108ad0:	68 f7 d4 10 c0       	push   $0xc010d4f7
c0108ad5:	e8 ac 82 ff ff       	call   c0100d86 <__panic>
c0108ada:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108add:	c1 e2 03             	shl    $0x3,%edx
c0108ae0:	6a 08                	push   $0x8
c0108ae2:	50                   	push   %eax
c0108ae3:	52                   	push   %edx
c0108ae4:	6a 01                	push   $0x1
c0108ae6:	e8 71 92 ff ff       	call   c0101d5c <ide_write_secs>
c0108aeb:	83 c4 10             	add    $0x10,%esp
}
c0108aee:	c9                   	leave  
c0108aef:	c3                   	ret    

c0108af0 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	# just like the preparation before the execution of int main(arg)
	# and save the return value of main on stack (by `return 0;` statement)	
    pushl %edx              # push arg
c0108af0:	52                   	push   %edx
    call *%ebx              # call fn
c0108af1:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0108af3:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0108af4:	e8 99 0b 00 00       	call   c0109692 <do_exit>

c0108af9 <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c0108af9:	55                   	push   %ebp
c0108afa:	89 e5                	mov    %esp,%ebp
c0108afc:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c0108aff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b05:	0f ab 02             	bts    %eax,(%edx)
c0108b08:	19 c0                	sbb    %eax,%eax
c0108b0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0108b0d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108b11:	0f 95 c0             	setne  %al
c0108b14:	0f b6 c0             	movzbl %al,%eax
}
c0108b17:	c9                   	leave  
c0108b18:	c3                   	ret    

c0108b19 <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c0108b19:	55                   	push   %ebp
c0108b1a:	89 e5                	mov    %esp,%ebp
c0108b1c:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c0108b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108b22:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b25:	0f b3 02             	btr    %eax,(%edx)
c0108b28:	19 c0                	sbb    %eax,%eax
c0108b2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0108b2d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108b31:	0f 95 c0             	setne  %al
c0108b34:	0f b6 c0             	movzbl %al,%eax
}
c0108b37:	c9                   	leave  
c0108b38:	c3                   	ret    

c0108b39 <page2ppn>:
page2ppn(struct Page *page) {
c0108b39:	55                   	push   %ebp
c0108b3a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108b3c:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0108b42:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b45:	29 d0                	sub    %edx,%eax
c0108b47:	c1 f8 05             	sar    $0x5,%eax
}
c0108b4a:	5d                   	pop    %ebp
c0108b4b:	c3                   	ret    

c0108b4c <page2pa>:
page2pa(struct Page *page) {
c0108b4c:	55                   	push   %ebp
c0108b4d:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0108b4f:	ff 75 08             	pushl  0x8(%ebp)
c0108b52:	e8 e2 ff ff ff       	call   c0108b39 <page2ppn>
c0108b57:	83 c4 04             	add    $0x4,%esp
c0108b5a:	c1 e0 0c             	shl    $0xc,%eax
}
c0108b5d:	c9                   	leave  
c0108b5e:	c3                   	ret    

c0108b5f <pa2page>:
pa2page(uintptr_t pa) {
c0108b5f:	55                   	push   %ebp
c0108b60:	89 e5                	mov    %esp,%ebp
c0108b62:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0108b65:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b68:	c1 e8 0c             	shr    $0xc,%eax
c0108b6b:	89 c2                	mov    %eax,%edx
c0108b6d:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0108b72:	39 c2                	cmp    %eax,%edx
c0108b74:	72 14                	jb     c0108b8a <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0108b76:	83 ec 04             	sub    $0x4,%esp
c0108b79:	68 28 d5 10 c0       	push   $0xc010d528
c0108b7e:	6a 5e                	push   $0x5e
c0108b80:	68 47 d5 10 c0       	push   $0xc010d547
c0108b85:	e8 fc 81 ff ff       	call   c0100d86 <__panic>
    return &pages[PPN(pa)];
c0108b8a:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0108b90:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b93:	c1 e8 0c             	shr    $0xc,%eax
c0108b96:	c1 e0 05             	shl    $0x5,%eax
c0108b99:	01 d0                	add    %edx,%eax
}
c0108b9b:	c9                   	leave  
c0108b9c:	c3                   	ret    

c0108b9d <page2kva>:
page2kva(struct Page *page) {
c0108b9d:	55                   	push   %ebp
c0108b9e:	89 e5                	mov    %esp,%ebp
c0108ba0:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0108ba3:	ff 75 08             	pushl  0x8(%ebp)
c0108ba6:	e8 a1 ff ff ff       	call   c0108b4c <page2pa>
c0108bab:	83 c4 04             	add    $0x4,%esp
c0108bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bb4:	c1 e8 0c             	shr    $0xc,%eax
c0108bb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108bba:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0108bbf:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108bc2:	72 14                	jb     c0108bd8 <page2kva+0x3b>
c0108bc4:	ff 75 f4             	pushl  -0xc(%ebp)
c0108bc7:	68 58 d5 10 c0       	push   $0xc010d558
c0108bcc:	6a 65                	push   $0x65
c0108bce:	68 47 d5 10 c0       	push   $0xc010d547
c0108bd3:	e8 ae 81 ff ff       	call   c0100d86 <__panic>
c0108bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bdb:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108be0:	c9                   	leave  
c0108be1:	c3                   	ret    

c0108be2 <kva2page>:
kva2page(void *kva) {
c0108be2:	55                   	push   %ebp
c0108be3:	89 e5                	mov    %esp,%ebp
c0108be5:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c0108be8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108bee:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0108bf5:	77 14                	ja     c0108c0b <kva2page+0x29>
c0108bf7:	ff 75 f4             	pushl  -0xc(%ebp)
c0108bfa:	68 7c d5 10 c0       	push   $0xc010d57c
c0108bff:	6a 6a                	push   $0x6a
c0108c01:	68 47 d5 10 c0       	push   $0xc010d547
c0108c06:	e8 7b 81 ff ff       	call   c0100d86 <__panic>
c0108c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c0e:	05 00 00 00 40       	add    $0x40000000,%eax
c0108c13:	83 ec 0c             	sub    $0xc,%esp
c0108c16:	50                   	push   %eax
c0108c17:	e8 43 ff ff ff       	call   c0108b5f <pa2page>
c0108c1c:	83 c4 10             	add    $0x10,%esp
}
c0108c1f:	c9                   	leave  
c0108c20:	c3                   	ret    

c0108c21 <__intr_save>:
__intr_save(void) {
c0108c21:	55                   	push   %ebp
c0108c22:	89 e5                	mov    %esp,%ebp
c0108c24:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0108c27:	9c                   	pushf  
c0108c28:	58                   	pop    %eax
c0108c29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0108c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0108c2f:	25 00 02 00 00       	and    $0x200,%eax
c0108c34:	85 c0                	test   %eax,%eax
c0108c36:	74 0c                	je     c0108c44 <__intr_save+0x23>
        intr_disable();
c0108c38:	e8 4e 93 ff ff       	call   c0101f8b <intr_disable>
        return 1;
c0108c3d:	b8 01 00 00 00       	mov    $0x1,%eax
c0108c42:	eb 05                	jmp    c0108c49 <__intr_save+0x28>
    return 0;
c0108c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c49:	c9                   	leave  
c0108c4a:	c3                   	ret    

c0108c4b <__intr_restore>:
__intr_restore(bool flag) {
c0108c4b:	55                   	push   %ebp
c0108c4c:	89 e5                	mov    %esp,%ebp
c0108c4e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0108c51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108c55:	74 05                	je     c0108c5c <__intr_restore+0x11>
        intr_enable();
c0108c57:	e8 27 93 ff ff       	call   c0101f83 <intr_enable>
}
c0108c5c:	90                   	nop
c0108c5d:	c9                   	leave  
c0108c5e:	c3                   	ret    

c0108c5f <try_lock>:

static inline bool
try_lock(lock_t *lock) {
c0108c5f:	55                   	push   %ebp
c0108c60:	89 e5                	mov    %esp,%ebp
    return !test_and_set_bit(0, lock);
c0108c62:	ff 75 08             	pushl  0x8(%ebp)
c0108c65:	6a 00                	push   $0x0
c0108c67:	e8 8d fe ff ff       	call   c0108af9 <test_and_set_bit>
c0108c6c:	83 c4 08             	add    $0x8,%esp
c0108c6f:	85 c0                	test   %eax,%eax
c0108c71:	0f 94 c0             	sete   %al
c0108c74:	0f b6 c0             	movzbl %al,%eax
}
c0108c77:	c9                   	leave  
c0108c78:	c3                   	ret    

c0108c79 <lock>:

static inline void
lock(lock_t *lock) {
c0108c79:	55                   	push   %ebp
c0108c7a:	89 e5                	mov    %esp,%ebp
c0108c7c:	83 ec 08             	sub    $0x8,%esp
    while (!try_lock(lock)) {
c0108c7f:	eb 05                	jmp    c0108c86 <lock+0xd>
        schedule();
c0108c81:	e8 77 19 00 00       	call   c010a5fd <schedule>
    while (!try_lock(lock)) {
c0108c86:	83 ec 0c             	sub    $0xc,%esp
c0108c89:	ff 75 08             	pushl  0x8(%ebp)
c0108c8c:	e8 ce ff ff ff       	call   c0108c5f <try_lock>
c0108c91:	83 c4 10             	add    $0x10,%esp
c0108c94:	85 c0                	test   %eax,%eax
c0108c96:	74 e9                	je     c0108c81 <lock+0x8>
    }
}
c0108c98:	90                   	nop
c0108c99:	90                   	nop
c0108c9a:	c9                   	leave  
c0108c9b:	c3                   	ret    

c0108c9c <unlock>:

static inline void
unlock(lock_t *lock) {
c0108c9c:	55                   	push   %ebp
c0108c9d:	89 e5                	mov    %esp,%ebp
c0108c9f:	83 ec 08             	sub    $0x8,%esp
    if (!test_and_clear_bit(0, lock)) {
c0108ca2:	ff 75 08             	pushl  0x8(%ebp)
c0108ca5:	6a 00                	push   $0x0
c0108ca7:	e8 6d fe ff ff       	call   c0108b19 <test_and_clear_bit>
c0108cac:	83 c4 08             	add    $0x8,%esp
c0108caf:	85 c0                	test   %eax,%eax
c0108cb1:	75 14                	jne    c0108cc7 <unlock+0x2b>
        panic("Unlock failed.\n");
c0108cb3:	83 ec 04             	sub    $0x4,%esp
c0108cb6:	68 a0 d5 10 c0       	push   $0xc010d5a0
c0108cbb:	6a 34                	push   $0x34
c0108cbd:	68 b0 d5 10 c0       	push   $0xc010d5b0
c0108cc2:	e8 bf 80 ff ff       	call   c0100d86 <__panic>
    }
}
c0108cc7:	90                   	nop
c0108cc8:	c9                   	leave  
c0108cc9:	c3                   	ret    

c0108cca <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c0108cca:	55                   	push   %ebp
c0108ccb:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c0108ccd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cd0:	8b 40 18             	mov    0x18(%eax),%eax
c0108cd3:	8d 50 01             	lea    0x1(%eax),%edx
c0108cd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cd9:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c0108cdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cdf:	8b 40 18             	mov    0x18(%eax),%eax
}
c0108ce2:	5d                   	pop    %ebp
c0108ce3:	c3                   	ret    

c0108ce4 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c0108ce4:	55                   	push   %ebp
c0108ce5:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c0108ce7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cea:	8b 40 18             	mov    0x18(%eax),%eax
c0108ced:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108cf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cf3:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c0108cf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cf9:	8b 40 18             	mov    0x18(%eax),%eax
}
c0108cfc:	5d                   	pop    %ebp
c0108cfd:	c3                   	ret    

c0108cfe <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c0108cfe:	55                   	push   %ebp
c0108cff:	89 e5                	mov    %esp,%ebp
c0108d01:	83 ec 08             	sub    $0x8,%esp
    if (mm != NULL) {
c0108d04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108d08:	74 12                	je     c0108d1c <lock_mm+0x1e>
        lock(&(mm->mm_lock));
c0108d0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d0d:	83 c0 1c             	add    $0x1c,%eax
c0108d10:	83 ec 0c             	sub    $0xc,%esp
c0108d13:	50                   	push   %eax
c0108d14:	e8 60 ff ff ff       	call   c0108c79 <lock>
c0108d19:	83 c4 10             	add    $0x10,%esp
    }
}
c0108d1c:	90                   	nop
c0108d1d:	c9                   	leave  
c0108d1e:	c3                   	ret    

c0108d1f <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c0108d1f:	55                   	push   %ebp
c0108d20:	89 e5                	mov    %esp,%ebp
c0108d22:	83 ec 08             	sub    $0x8,%esp
    if (mm != NULL) {
c0108d25:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108d29:	74 12                	je     c0108d3d <unlock_mm+0x1e>
        unlock(&(mm->mm_lock));
c0108d2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d2e:	83 c0 1c             	add    $0x1c,%eax
c0108d31:	83 ec 0c             	sub    $0xc,%esp
c0108d34:	50                   	push   %eax
c0108d35:	e8 62 ff ff ff       	call   c0108c9c <unlock>
c0108d3a:	83 c4 10             	add    $0x10,%esp
    }
}
c0108d3d:	90                   	nop
c0108d3e:	c9                   	leave  
c0108d3f:	c3                   	ret    

c0108d40 <alloc_proc>:
void
switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0108d40:	55                   	push   %ebp
c0108d41:	89 e5                	mov    %esp,%ebp
c0108d43:	83 ec 18             	sub    $0x18,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0108d46:	83 ec 0c             	sub    $0xc,%esp
c0108d49:	6a 7c                	push   $0x7c
c0108d4b:	e8 e0 bd ff ff       	call   c0104b30 <kmalloc>
c0108d50:	83 c4 10             	add    $0x10,%esp
c0108d53:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0108d56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108d5a:	74 31                	je     c0108d8d <alloc_proc+0x4d>
        /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
        memset(proc, 0, sizeof(struct proc_struct));
c0108d5c:	83 ec 04             	sub    $0x4,%esp
c0108d5f:	6a 7c                	push   $0x7c
c0108d61:	6a 00                	push   $0x0
c0108d63:	ff 75 f4             	pushl  -0xc(%ebp)
c0108d66:	e8 79 25 00 00       	call   c010b2e4 <memset>
c0108d6b:	83 c4 10             	add    $0x10,%esp
        proc->state = PROC_UNINIT;
c0108d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0108d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d7a:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->cr3 = boot_cr3;
c0108d81:	8b 15 a8 3f 1a c0    	mov    0xc01a3fa8,%edx
c0108d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d8a:	89 50 40             	mov    %edx,0x40(%eax)
        //proc->wait_state =
    }
    return proc;
c0108d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108d90:	c9                   	leave  
c0108d91:	c3                   	ret    

c0108d92 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0108d92:	55                   	push   %ebp
c0108d93:	89 e5                	mov    %esp,%ebp
c0108d95:	83 ec 08             	sub    $0x8,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0108d98:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d9b:	83 c0 48             	add    $0x48,%eax
c0108d9e:	83 ec 04             	sub    $0x4,%esp
c0108da1:	6a 10                	push   $0x10
c0108da3:	6a 00                	push   $0x0
c0108da5:	50                   	push   %eax
c0108da6:	e8 39 25 00 00       	call   c010b2e4 <memset>
c0108dab:	83 c4 10             	add    $0x10,%esp
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0108dae:	8b 45 08             	mov    0x8(%ebp),%eax
c0108db1:	83 c0 48             	add    $0x48,%eax
c0108db4:	83 ec 04             	sub    $0x4,%esp
c0108db7:	6a 0f                	push   $0xf
c0108db9:	ff 75 0c             	pushl  0xc(%ebp)
c0108dbc:	50                   	push   %eax
c0108dbd:	e8 03 26 00 00       	call   c010b3c5 <memcpy>
c0108dc2:	83 c4 10             	add    $0x10,%esp
}
c0108dc5:	c9                   	leave  
c0108dc6:	c3                   	ret    

c0108dc7 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0108dc7:	55                   	push   %ebp
c0108dc8:	89 e5                	mov    %esp,%ebp
c0108dca:	83 ec 08             	sub    $0x8,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0108dcd:	83 ec 04             	sub    $0x4,%esp
c0108dd0:	6a 10                	push   $0x10
c0108dd2:	6a 00                	push   $0x0
c0108dd4:	68 44 61 1a c0       	push   $0xc01a6144
c0108dd9:	e8 06 25 00 00       	call   c010b2e4 <memset>
c0108dde:	83 c4 10             	add    $0x10,%esp
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0108de1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108de4:	83 c0 48             	add    $0x48,%eax
c0108de7:	83 ec 04             	sub    $0x4,%esp
c0108dea:	6a 0f                	push   $0xf
c0108dec:	50                   	push   %eax
c0108ded:	68 44 61 1a c0       	push   $0xc01a6144
c0108df2:	e8 ce 25 00 00       	call   c010b3c5 <memcpy>
c0108df7:	83 c4 10             	add    $0x10,%esp
}
c0108dfa:	c9                   	leave  
c0108dfb:	c3                   	ret    

c0108dfc <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0108dfc:	55                   	push   %ebp
c0108dfd:	89 e5                	mov    %esp,%ebp
c0108dff:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c0108e02:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e05:	83 c0 58             	add    $0x58,%eax
c0108e08:	c7 45 fc 20 41 1a c0 	movl   $0xc01a4120,-0x4(%ebp)
c0108e0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0108e12:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108e18:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108e1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e21:	8b 40 04             	mov    0x4(%eax),%eax
c0108e24:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108e27:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108e2d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108e30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next->prev = elm;
c0108e33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e36:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108e39:	89 10                	mov    %edx,(%eax)
c0108e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e3e:	8b 10                	mov    (%eax),%edx
c0108e40:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e43:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108e46:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108e4c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108e4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e52:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108e55:	89 10                	mov    %edx,(%eax)
}
c0108e57:	90                   	nop
}
c0108e58:	90                   	nop
}
c0108e59:	90                   	nop
    proc->yptr = NULL;
c0108e5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e5d:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c0108e64:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e67:	8b 40 14             	mov    0x14(%eax),%eax
c0108e6a:	8b 50 70             	mov    0x70(%eax),%edx
c0108e6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e70:	89 50 78             	mov    %edx,0x78(%eax)
c0108e73:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e76:	8b 40 78             	mov    0x78(%eax),%eax
c0108e79:	85 c0                	test   %eax,%eax
c0108e7b:	74 0c                	je     c0108e89 <set_links+0x8d>
        proc->optr->yptr = proc;
c0108e7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e80:	8b 40 78             	mov    0x78(%eax),%eax
c0108e83:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e86:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c0108e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e8c:	8b 40 14             	mov    0x14(%eax),%eax
c0108e8f:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e92:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process++;
c0108e95:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c0108e9a:	83 c0 01             	add    $0x1,%eax
c0108e9d:	a3 40 61 1a c0       	mov    %eax,0xc01a6140
}
c0108ea2:	90                   	nop
c0108ea3:	c9                   	leave  
c0108ea4:	c3                   	ret    

c0108ea5 <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c0108ea5:	55                   	push   %ebp
c0108ea6:	89 e5                	mov    %esp,%ebp
c0108ea8:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0108eab:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eae:	83 c0 58             	add    $0x58,%eax
c0108eb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0108eb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108eb7:	8b 40 04             	mov    0x4(%eax),%eax
c0108eba:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108ebd:	8b 12                	mov    (%edx),%edx
c0108ebf:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108ec2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0108ec5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108ec8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ecb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ed1:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108ed4:	89 10                	mov    %edx,(%eax)
}
c0108ed6:	90                   	nop
}
c0108ed7:	90                   	nop
    if (proc->optr != NULL) {
c0108ed8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108edb:	8b 40 78             	mov    0x78(%eax),%eax
c0108ede:	85 c0                	test   %eax,%eax
c0108ee0:	74 0f                	je     c0108ef1 <remove_links+0x4c>
        proc->optr->yptr = proc->yptr;
c0108ee2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ee5:	8b 40 78             	mov    0x78(%eax),%eax
c0108ee8:	8b 55 08             	mov    0x8(%ebp),%edx
c0108eeb:	8b 52 74             	mov    0x74(%edx),%edx
c0108eee:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c0108ef1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ef4:	8b 40 74             	mov    0x74(%eax),%eax
c0108ef7:	85 c0                	test   %eax,%eax
c0108ef9:	74 11                	je     c0108f0c <remove_links+0x67>
        proc->yptr->optr = proc->optr;
c0108efb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108efe:	8b 40 74             	mov    0x74(%eax),%eax
c0108f01:	8b 55 08             	mov    0x8(%ebp),%edx
c0108f04:	8b 52 78             	mov    0x78(%edx),%edx
c0108f07:	89 50 78             	mov    %edx,0x78(%eax)
c0108f0a:	eb 0f                	jmp    c0108f1b <remove_links+0x76>
    } else {
        proc->parent->cptr = proc->optr;
c0108f0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f0f:	8b 40 14             	mov    0x14(%eax),%eax
c0108f12:	8b 55 08             	mov    0x8(%ebp),%edx
c0108f15:	8b 52 78             	mov    0x78(%edx),%edx
c0108f18:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process--;
c0108f1b:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c0108f20:	83 e8 01             	sub    $0x1,%eax
c0108f23:	a3 40 61 1a c0       	mov    %eax,0xc01a6140
}
c0108f28:	90                   	nop
c0108f29:	c9                   	leave  
c0108f2a:	c3                   	ret    

c0108f2b <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0108f2b:	55                   	push   %ebp
c0108f2c:	89 e5                	mov    %esp,%ebp
c0108f2e:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0108f31:	c7 45 f8 20 41 1a c0 	movl   $0xc01a4120,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID) {
c0108f38:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0108f3d:	83 c0 01             	add    $0x1,%eax
c0108f40:	a3 80 fa 12 c0       	mov    %eax,0xc012fa80
c0108f45:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0108f4a:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108f4f:	7e 0c                	jle    c0108f5d <get_pid+0x32>
        last_pid = 1;
c0108f51:	c7 05 80 fa 12 c0 01 	movl   $0x1,0xc012fa80
c0108f58:	00 00 00 
        goto inside;
c0108f5b:	eb 14                	jmp    c0108f71 <get_pid+0x46>
    }
    if (last_pid >= next_safe) {
c0108f5d:	8b 15 80 fa 12 c0    	mov    0xc012fa80,%edx
c0108f63:	a1 84 fa 12 c0       	mov    0xc012fa84,%eax
c0108f68:	39 c2                	cmp    %eax,%edx
c0108f6a:	0f 8c ad 00 00 00    	jl     c010901d <get_pid+0xf2>
    inside:
c0108f70:	90                   	nop
        next_safe = MAX_PID;
c0108f71:	c7 05 84 fa 12 c0 00 	movl   $0x2000,0xc012fa84
c0108f78:	20 00 00 
    repeat:
        le = list;
c0108f7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108f7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0108f81:	eb 7f                	jmp    c0109002 <get_pid+0xd7>
            proc = le2proc(le, list_link);
c0108f83:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f86:	83 e8 58             	sub    $0x58,%eax
c0108f89:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0108f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f8f:	8b 50 04             	mov    0x4(%eax),%edx
c0108f92:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0108f97:	39 c2                	cmp    %eax,%edx
c0108f99:	75 3e                	jne    c0108fd9 <get_pid+0xae>
                if (++last_pid >= next_safe) {
c0108f9b:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0108fa0:	83 c0 01             	add    $0x1,%eax
c0108fa3:	a3 80 fa 12 c0       	mov    %eax,0xc012fa80
c0108fa8:	8b 15 80 fa 12 c0    	mov    0xc012fa80,%edx
c0108fae:	a1 84 fa 12 c0       	mov    0xc012fa84,%eax
c0108fb3:	39 c2                	cmp    %eax,%edx
c0108fb5:	7c 4b                	jl     c0109002 <get_pid+0xd7>
                    if (last_pid >= MAX_PID) {
c0108fb7:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0108fbc:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108fc1:	7e 0a                	jle    c0108fcd <get_pid+0xa2>
                        last_pid = 1;
c0108fc3:	c7 05 80 fa 12 c0 01 	movl   $0x1,0xc012fa80
c0108fca:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108fcd:	c7 05 84 fa 12 c0 00 	movl   $0x2000,0xc012fa84
c0108fd4:	20 00 00 
                    goto repeat;
c0108fd7:	eb a2                	jmp    c0108f7b <get_pid+0x50>
                }
            } else if (proc->pid > last_pid && next_safe > proc->pid) {
c0108fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fdc:	8b 50 04             	mov    0x4(%eax),%edx
c0108fdf:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0108fe4:	39 c2                	cmp    %eax,%edx
c0108fe6:	7e 1a                	jle    c0109002 <get_pid+0xd7>
c0108fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108feb:	8b 50 04             	mov    0x4(%eax),%edx
c0108fee:	a1 84 fa 12 c0       	mov    0xc012fa84,%eax
c0108ff3:	39 c2                	cmp    %eax,%edx
c0108ff5:	7d 0b                	jge    c0109002 <get_pid+0xd7>
                next_safe = proc->pid;
c0108ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ffa:	8b 40 04             	mov    0x4(%eax),%eax
c0108ffd:	a3 84 fa 12 c0       	mov    %eax,0xc012fa84
c0109002:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109005:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return listelm->next;
c0109008:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010900b:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c010900e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109011:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109014:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109017:	0f 85 66 ff ff ff    	jne    c0108f83 <get_pid+0x58>
            }
        }
    }
    return last_pid;
c010901d:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
}
c0109022:	c9                   	leave  
c0109023:	c3                   	ret    

c0109024 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109024:	55                   	push   %ebp
c0109025:	89 e5                	mov    %esp,%ebp
c0109027:	83 ec 18             	sub    $0x18,%esp
    if (proc != current) {
c010902a:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010902f:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109032:	74 6c                	je     c01090a0 <proc_run+0x7c>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109034:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109039:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010903c:	8b 45 08             	mov    0x8(%ebp),%eax
c010903f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109042:	e8 da fb ff ff       	call   c0108c21 <__intr_save>
c0109047:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c010904a:	8b 45 08             	mov    0x8(%ebp),%eax
c010904d:	a3 30 41 1a c0       	mov    %eax,0xc01a4130
            load_esp0(next->kstack + KSTACKSIZE);
c0109052:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109055:	8b 40 0c             	mov    0xc(%eax),%eax
c0109058:	05 00 20 00 00       	add    $0x2000,%eax
c010905d:	83 ec 0c             	sub    $0xc,%esp
c0109060:	50                   	push   %eax
c0109061:	e8 e8 bd ff ff       	call   c0104e4e <load_esp0>
c0109066:	83 c4 10             	add    $0x10,%esp
            lcr3(next->cr3);
c0109069:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010906c:	8b 40 40             	mov    0x40(%eax),%eax
c010906f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109072:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109075:	0f 22 d8             	mov    %eax,%cr3
}
c0109078:	90                   	nop
            switch_to(&(prev->context), &(next->context));
c0109079:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010907c:	8d 50 1c             	lea    0x1c(%eax),%edx
c010907f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109082:	83 c0 1c             	add    $0x1c,%eax
c0109085:	83 ec 08             	sub    $0x8,%esp
c0109088:	52                   	push   %edx
c0109089:	50                   	push   %eax
c010908a:	e8 84 14 00 00       	call   c010a513 <switch_to>
c010908f:	83 c4 10             	add    $0x10,%esp
        }
        local_intr_restore(intr_flag);
c0109092:	83 ec 0c             	sub    $0xc,%esp
c0109095:	ff 75 ec             	pushl  -0x14(%ebp)
c0109098:	e8 ae fb ff ff       	call   c0108c4b <__intr_restore>
c010909d:	83 c4 10             	add    $0x10,%esp
    }
}
c01090a0:	90                   	nop
c01090a1:	c9                   	leave  
c01090a2:	c3                   	ret    

c01090a3 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c01090a3:	55                   	push   %ebp
c01090a4:	89 e5                	mov    %esp,%ebp
c01090a6:	83 ec 08             	sub    $0x8,%esp
    forkrets(current->tf);
c01090a9:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01090ae:	8b 40 3c             	mov    0x3c(%eax),%eax
c01090b1:	83 ec 0c             	sub    $0xc,%esp
c01090b4:	50                   	push   %eax
c01090b5:	e8 82 99 ff ff       	call   c0102a3c <forkrets>
c01090ba:	83 c4 10             	add    $0x10,%esp
}
c01090bd:	90                   	nop
c01090be:	c9                   	leave  
c01090bf:	c3                   	ret    

c01090c0 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c01090c0:	55                   	push   %ebp
c01090c1:	89 e5                	mov    %esp,%ebp
c01090c3:	53                   	push   %ebx
c01090c4:	83 ec 24             	sub    $0x24,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c01090c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01090ca:	8d 58 60             	lea    0x60(%eax),%ebx
c01090cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01090d0:	8b 40 04             	mov    0x4(%eax),%eax
c01090d3:	83 ec 08             	sub    $0x8,%esp
c01090d6:	6a 0a                	push   $0xa
c01090d8:	50                   	push   %eax
c01090d9:	e8 d3 17 00 00       	call   c010a8b1 <hash32>
c01090de:	83 c4 10             	add    $0x10,%esp
c01090e1:	c1 e0 03             	shl    $0x3,%eax
c01090e4:	05 40 41 1a c0       	add    $0xc01a4140,%eax
c01090e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090ec:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c01090ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01090f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c01090fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090fe:	8b 40 04             	mov    0x4(%eax),%eax
c0109101:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109104:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109107:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010910a:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010910d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0109110:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109113:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109116:	89 10                	mov    %edx,(%eax)
c0109118:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010911b:	8b 10                	mov    (%eax),%edx
c010911d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109120:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109123:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109126:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109129:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010912c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010912f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109132:	89 10                	mov    %edx,(%eax)
}
c0109134:	90                   	nop
}
c0109135:	90                   	nop
}
c0109136:	90                   	nop
}
c0109137:	90                   	nop
c0109138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010913b:	c9                   	leave  
c010913c:	c3                   	ret    

c010913d <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c010913d:	55                   	push   %ebp
c010913e:	89 e5                	mov    %esp,%ebp
c0109140:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109143:	8b 45 08             	mov    0x8(%ebp),%eax
c0109146:	83 c0 60             	add    $0x60,%eax
c0109149:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c010914c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010914f:	8b 40 04             	mov    0x4(%eax),%eax
c0109152:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109155:	8b 12                	mov    (%edx),%edx
c0109157:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010915a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c010915d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109160:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109163:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109166:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109169:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010916c:	89 10                	mov    %edx,(%eax)
}
c010916e:	90                   	nop
}
c010916f:	90                   	nop
}
c0109170:	90                   	nop
c0109171:	c9                   	leave  
c0109172:	c3                   	ret    

c0109173 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109173:	55                   	push   %ebp
c0109174:	89 e5                	mov    %esp,%ebp
c0109176:	83 ec 18             	sub    $0x18,%esp
    if (0 < pid && pid < MAX_PID) {
c0109179:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010917d:	7e 5d                	jle    c01091dc <find_proc+0x69>
c010917f:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109186:	7f 54                	jg     c01091dc <find_proc+0x69>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109188:	8b 45 08             	mov    0x8(%ebp),%eax
c010918b:	83 ec 08             	sub    $0x8,%esp
c010918e:	6a 0a                	push   $0xa
c0109190:	50                   	push   %eax
c0109191:	e8 1b 17 00 00       	call   c010a8b1 <hash32>
c0109196:	83 c4 10             	add    $0x10,%esp
c0109199:	c1 e0 03             	shl    $0x3,%eax
c010919c:	05 40 41 1a c0       	add    $0xc01a4140,%eax
c01091a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01091a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01091a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c01091aa:	eb 19                	jmp    c01091c5 <find_proc+0x52>
            struct proc_struct *proc = le2proc(le, hash_link);
c01091ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091af:	83 e8 60             	sub    $0x60,%eax
c01091b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c01091b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01091b8:	8b 40 04             	mov    0x4(%eax),%eax
c01091bb:	39 45 08             	cmp    %eax,0x8(%ebp)
c01091be:	75 05                	jne    c01091c5 <find_proc+0x52>
                return proc;
c01091c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01091c3:	eb 1c                	jmp    c01091e1 <find_proc+0x6e>
c01091c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c01091cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091ce:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01091d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01091d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091d7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01091da:	75 d0                	jne    c01091ac <find_proc+0x39>
            }
        }
    }
    return NULL;
c01091dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01091e1:	c9                   	leave  
c01091e2:	c3                   	ret    

c01091e3 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c01091e3:	55                   	push   %ebp
c01091e4:	89 e5                	mov    %esp,%ebp
c01091e6:	83 ec 58             	sub    $0x58,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c01091e9:	83 ec 04             	sub    $0x4,%esp
c01091ec:	6a 4c                	push   $0x4c
c01091ee:	6a 00                	push   $0x0
c01091f0:	8d 45 ac             	lea    -0x54(%ebp),%eax
c01091f3:	50                   	push   %eax
c01091f4:	e8 eb 20 00 00       	call   c010b2e4 <memset>
c01091f9:	83 c4 10             	add    $0x10,%esp
    tf.tf_cs = KERNEL_CS;
c01091fc:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109202:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109208:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010920c:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109210:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109214:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109218:	8b 45 08             	mov    0x8(%ebp),%eax
c010921b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c010921e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109221:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109224:	b8 f0 8a 10 c0       	mov    $0xc0108af0,%eax
c0109229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c010922c:	8b 45 10             	mov    0x10(%ebp),%eax
c010922f:	80 cc 01             	or     $0x1,%ah
c0109232:	89 c2                	mov    %eax,%edx
c0109234:	83 ec 04             	sub    $0x4,%esp
c0109237:	8d 45 ac             	lea    -0x54(%ebp),%eax
c010923a:	50                   	push   %eax
c010923b:	6a 00                	push   $0x0
c010923d:	52                   	push   %edx
c010923e:	e8 f3 02 00 00       	call   c0109536 <do_fork>
c0109243:	83 c4 10             	add    $0x10,%esp
}
c0109246:	c9                   	leave  
c0109247:	c3                   	ret    

c0109248 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109248:	55                   	push   %ebp
c0109249:	89 e5                	mov    %esp,%ebp
c010924b:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c010924e:	83 ec 0c             	sub    $0xc,%esp
c0109251:	6a 02                	push   $0x2
c0109253:	e8 4b bd ff ff       	call   c0104fa3 <alloc_pages>
c0109258:	83 c4 10             	add    $0x10,%esp
c010925b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010925e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109262:	74 1d                	je     c0109281 <setup_kstack+0x39>
        proc->kstack = (uintptr_t)page2kva(page);
c0109264:	83 ec 0c             	sub    $0xc,%esp
c0109267:	ff 75 f4             	pushl  -0xc(%ebp)
c010926a:	e8 2e f9 ff ff       	call   c0108b9d <page2kva>
c010926f:	83 c4 10             	add    $0x10,%esp
c0109272:	89 c2                	mov    %eax,%edx
c0109274:	8b 45 08             	mov    0x8(%ebp),%eax
c0109277:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c010927a:	b8 00 00 00 00       	mov    $0x0,%eax
c010927f:	eb 05                	jmp    c0109286 <setup_kstack+0x3e>
    }
    return -E_NO_MEM;
c0109281:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109286:	c9                   	leave  
c0109287:	c3                   	ret    

c0109288 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109288:	55                   	push   %ebp
c0109289:	89 e5                	mov    %esp,%ebp
c010928b:	83 ec 08             	sub    $0x8,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c010928e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109291:	8b 40 0c             	mov    0xc(%eax),%eax
c0109294:	83 ec 0c             	sub    $0xc,%esp
c0109297:	50                   	push   %eax
c0109298:	e8 45 f9 ff ff       	call   c0108be2 <kva2page>
c010929d:	83 c4 10             	add    $0x10,%esp
c01092a0:	83 ec 08             	sub    $0x8,%esp
c01092a3:	6a 02                	push   $0x2
c01092a5:	50                   	push   %eax
c01092a6:	e8 64 bd ff ff       	call   c010500f <free_pages>
c01092ab:	83 c4 10             	add    $0x10,%esp
}
c01092ae:	90                   	nop
c01092af:	c9                   	leave  
c01092b0:	c3                   	ret    

c01092b1 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c01092b1:	55                   	push   %ebp
c01092b2:	89 e5                	mov    %esp,%ebp
c01092b4:	83 ec 18             	sub    $0x18,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c01092b7:	83 ec 0c             	sub    $0xc,%esp
c01092ba:	6a 01                	push   $0x1
c01092bc:	e8 e2 bc ff ff       	call   c0104fa3 <alloc_pages>
c01092c1:	83 c4 10             	add    $0x10,%esp
c01092c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01092c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01092cb:	75 07                	jne    c01092d4 <setup_pgdir+0x23>
        return -E_NO_MEM;
c01092cd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01092d2:	eb 74                	jmp    c0109348 <setup_pgdir+0x97>
    }
    pde_t *pgdir = page2kva(page);
c01092d4:	83 ec 0c             	sub    $0xc,%esp
c01092d7:	ff 75 f4             	pushl  -0xc(%ebp)
c01092da:	e8 be f8 ff ff       	call   c0108b9d <page2kva>
c01092df:	83 c4 10             	add    $0x10,%esp
c01092e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c01092e5:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01092ea:	83 ec 04             	sub    $0x4,%esp
c01092ed:	68 00 10 00 00       	push   $0x1000
c01092f2:	50                   	push   %eax
c01092f3:	ff 75 f0             	pushl  -0x10(%ebp)
c01092f6:	e8 ca 20 00 00       	call   c010b3c5 <memcpy>
c01092fb:	83 c4 10             	add    $0x10,%esp
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c01092fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109301:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109304:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c010930b:	77 17                	ja     c0109324 <setup_pgdir+0x73>
c010930d:	ff 75 ec             	pushl  -0x14(%ebp)
c0109310:	68 7c d5 10 c0       	push   $0xc010d57c
c0109315:	68 26 01 00 00       	push   $0x126
c010931a:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010931f:	e8 62 7a ff ff       	call   c0100d86 <__panic>
c0109324:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109327:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010932d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109330:	05 ac 0f 00 00       	add    $0xfac,%eax
c0109335:	83 ca 03             	or     $0x3,%edx
c0109338:	89 10                	mov    %edx,(%eax)
    mm->pgdir = pgdir;
c010933a:	8b 45 08             	mov    0x8(%ebp),%eax
c010933d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109340:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109343:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109348:	c9                   	leave  
c0109349:	c3                   	ret    

c010934a <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c010934a:	55                   	push   %ebp
c010934b:	89 e5                	mov    %esp,%ebp
c010934d:	83 ec 08             	sub    $0x8,%esp
    free_page(kva2page(mm->pgdir));
c0109350:	8b 45 08             	mov    0x8(%ebp),%eax
c0109353:	8b 40 0c             	mov    0xc(%eax),%eax
c0109356:	83 ec 0c             	sub    $0xc,%esp
c0109359:	50                   	push   %eax
c010935a:	e8 83 f8 ff ff       	call   c0108be2 <kva2page>
c010935f:	83 c4 10             	add    $0x10,%esp
c0109362:	83 ec 08             	sub    $0x8,%esp
c0109365:	6a 01                	push   $0x1
c0109367:	50                   	push   %eax
c0109368:	e8 a2 bc ff ff       	call   c010500f <free_pages>
c010936d:	83 c4 10             	add    $0x10,%esp
}
c0109370:	90                   	nop
c0109371:	c9                   	leave  
c0109372:	c3                   	ret    

c0109373 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109373:	55                   	push   %ebp
c0109374:	89 e5                	mov    %esp,%ebp
c0109376:	83 ec 18             	sub    $0x18,%esp
    //@mm is new proc's mm_struct, @oldmm is as its name
    struct mm_struct *mm, *oldmm = current->mm;
c0109379:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010937e:	8b 40 18             	mov    0x18(%eax),%eax
c0109381:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109384:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109388:	75 0a                	jne    c0109394 <copy_mm+0x21>
        return 0;
c010938a:	b8 00 00 00 00       	mov    $0x0,%eax
c010938f:	e9 04 01 00 00       	jmp    c0109498 <copy_mm+0x125>
    }
    if (clone_flags & CLONE_VM) {
c0109394:	8b 45 08             	mov    0x8(%ebp),%eax
c0109397:	25 00 01 00 00       	and    $0x100,%eax
c010939c:	85 c0                	test   %eax,%eax
c010939e:	74 08                	je     c01093a8 <copy_mm+0x35>
        mm = oldmm;
c01093a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01093a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c01093a6:	eb 66                	jmp    c010940e <copy_mm+0x9b>
    }

    int ret = -E_NO_MEM;
c01093a8:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c01093af:	e8 97 e5 ff ff       	call   c010794b <mm_create>
c01093b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01093b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01093bb:	0f 84 d3 00 00 00    	je     c0109494 <copy_mm+0x121>
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
c01093c1:	83 ec 0c             	sub    $0xc,%esp
c01093c4:	ff 75 f4             	pushl  -0xc(%ebp)
c01093c7:	e8 e5 fe ff ff       	call   c01092b1 <setup_pgdir>
c01093cc:	83 c4 10             	add    $0x10,%esp
c01093cf:	85 c0                	test   %eax,%eax
c01093d1:	0f 85 ac 00 00 00    	jne    c0109483 <copy_mm+0x110>
        goto bad_pgdir_cleanup_mm;
    }

    lock_mm(oldmm);
c01093d7:	83 ec 0c             	sub    $0xc,%esp
c01093da:	ff 75 ec             	pushl  -0x14(%ebp)
c01093dd:	e8 1c f9 ff ff       	call   c0108cfe <lock_mm>
c01093e2:	83 c4 10             	add    $0x10,%esp
    {
        ret = dup_mmap(mm, oldmm);
c01093e5:	83 ec 08             	sub    $0x8,%esp
c01093e8:	ff 75 ec             	pushl  -0x14(%ebp)
c01093eb:	ff 75 f4             	pushl  -0xc(%ebp)
c01093ee:	e8 2e ea ff ff       	call   c0107e21 <dup_mmap>
c01093f3:	83 c4 10             	add    $0x10,%esp
c01093f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c01093f9:	83 ec 0c             	sub    $0xc,%esp
c01093fc:	ff 75 ec             	pushl  -0x14(%ebp)
c01093ff:	e8 1b f9 ff ff       	call   c0108d1f <unlock_mm>
c0109404:	83 c4 10             	add    $0x10,%esp

    if (ret != 0) {
c0109407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010940b:	75 57                	jne    c0109464 <copy_mm+0xf1>
        goto bad_dup_cleanup_mmap;
    }

good_mm:
c010940d:	90                   	nop
    mm_count_inc(mm);
c010940e:	83 ec 0c             	sub    $0xc,%esp
c0109411:	ff 75 f4             	pushl  -0xc(%ebp)
c0109414:	e8 b1 f8 ff ff       	call   c0108cca <mm_count_inc>
c0109419:	83 c4 10             	add    $0x10,%esp
    proc->mm = mm;
c010941c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010941f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109422:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109425:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109428:	8b 40 0c             	mov    0xc(%eax),%eax
c010942b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010942e:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109435:	77 17                	ja     c010944e <copy_mm+0xdb>
c0109437:	ff 75 e8             	pushl  -0x18(%ebp)
c010943a:	68 7c d5 10 c0       	push   $0xc010d57c
c010943f:	68 56 01 00 00       	push   $0x156
c0109444:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109449:	e8 38 79 ff ff       	call   c0100d86 <__panic>
c010944e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109451:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109457:	8b 45 0c             	mov    0xc(%ebp),%eax
c010945a:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c010945d:	b8 00 00 00 00       	mov    $0x0,%eax
c0109462:	eb 34                	jmp    c0109498 <copy_mm+0x125>
        goto bad_dup_cleanup_mmap;
c0109464:	90                   	nop
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109465:	83 ec 0c             	sub    $0xc,%esp
c0109468:	ff 75 f4             	pushl  -0xc(%ebp)
c010946b:	e8 98 ea ff ff       	call   c0107f08 <exit_mmap>
c0109470:	83 c4 10             	add    $0x10,%esp
    put_pgdir(mm);
c0109473:	83 ec 0c             	sub    $0xc,%esp
c0109476:	ff 75 f4             	pushl  -0xc(%ebp)
c0109479:	e8 cc fe ff ff       	call   c010934a <put_pgdir>
c010947e:	83 c4 10             	add    $0x10,%esp
c0109481:	eb 01                	jmp    c0109484 <copy_mm+0x111>
        goto bad_pgdir_cleanup_mm;
c0109483:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109484:	83 ec 0c             	sub    $0xc,%esp
c0109487:	ff 75 f4             	pushl  -0xc(%ebp)
c010948a:	e8 e9 e7 ff ff       	call   c0107c78 <mm_destroy>
c010948f:	83 c4 10             	add    $0x10,%esp
c0109492:	eb 01                	jmp    c0109495 <copy_mm+0x122>
        goto bad_mm;
c0109494:	90                   	nop
bad_mm:
    return ret;
c0109495:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109498:	c9                   	leave  
c0109499:	c3                   	ret    

c010949a <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c010949a:	55                   	push   %ebp
c010949b:	89 e5                	mov    %esp,%ebp
c010949d:	57                   	push   %edi
c010949e:	56                   	push   %esi
c010949f:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c01094a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01094a3:	8b 40 0c             	mov    0xc(%eax),%eax
c01094a6:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c01094ab:	89 c2                	mov    %eax,%edx
c01094ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b0:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c01094b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01094b6:	8b 50 3c             	mov    0x3c(%eax),%edx
c01094b9:	8b 45 10             	mov    0x10(%ebp),%eax
c01094bc:	89 d1                	mov    %edx,%ecx
c01094be:	ba 4c 00 00 00       	mov    $0x4c,%edx
c01094c3:	8b 18                	mov    (%eax),%ebx
c01094c5:	89 19                	mov    %ebx,(%ecx)
c01094c7:	8b 5c 10 fc          	mov    -0x4(%eax,%edx,1),%ebx
c01094cb:	89 5c 11 fc          	mov    %ebx,-0x4(%ecx,%edx,1)
c01094cf:	8d 59 04             	lea    0x4(%ecx),%ebx
c01094d2:	83 e3 fc             	and    $0xfffffffc,%ebx
c01094d5:	29 d9                	sub    %ebx,%ecx
c01094d7:	29 c8                	sub    %ecx,%eax
c01094d9:	01 ca                	add    %ecx,%edx
c01094db:	83 e2 fc             	and    $0xfffffffc,%edx
c01094de:	c1 ea 02             	shr    $0x2,%edx
c01094e1:	89 df                	mov    %ebx,%edi
c01094e3:	89 c6                	mov    %eax,%esi
c01094e5:	89 d1                	mov    %edx,%ecx
c01094e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    proc->tf->tf_regs.reg_eax = 0;
c01094e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ec:	8b 40 3c             	mov    0x3c(%eax),%eax
c01094ef:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c01094f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01094f9:	8b 40 3c             	mov    0x3c(%eax),%eax
c01094fc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01094ff:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109502:	8b 45 08             	mov    0x8(%ebp),%eax
c0109505:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109508:	8b 50 40             	mov    0x40(%eax),%edx
c010950b:	8b 45 08             	mov    0x8(%ebp),%eax
c010950e:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109511:	80 ce 02             	or     $0x2,%dh
c0109514:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109517:	ba a3 90 10 c0       	mov    $0xc01090a3,%edx
c010951c:	8b 45 08             	mov    0x8(%ebp),%eax
c010951f:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109522:	8b 45 08             	mov    0x8(%ebp),%eax
c0109525:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109528:	89 c2                	mov    %eax,%edx
c010952a:	8b 45 08             	mov    0x8(%ebp),%eax
c010952d:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109530:	90                   	nop
c0109531:	5b                   	pop    %ebx
c0109532:	5e                   	pop    %esi
c0109533:	5f                   	pop    %edi
c0109534:	5d                   	pop    %ebp
c0109535:	c3                   	ret    

c0109536 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109536:	55                   	push   %ebp
c0109537:	89 e5                	mov    %esp,%ebp
c0109539:	83 ec 18             	sub    $0x18,%esp
    int ret = -E_NO_FREE_PROC;
c010953c:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109543:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c0109548:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010954d:	0f 8f 27 01 00 00    	jg     c010967a <do_fork+0x144>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0109553:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
    if ((proc = alloc_proc()) == NULL) {
c010955a:	e8 e1 f7 ff ff       	call   c0108d40 <alloc_proc>
c010955f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109562:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109566:	75 15                	jne    c010957d <do_fork+0x47>
        cprintf("alloc_proc() failed!");
c0109568:	83 ec 0c             	sub    $0xc,%esp
c010956b:	68 d5 d5 10 c0       	push   $0xc010d5d5
c0109570:	e8 d3 6d ff ff       	call   c0100348 <cprintf>
c0109575:	83 c4 10             	add    $0x10,%esp
        goto fork_out;
c0109578:	e9 fe 00 00 00       	jmp    c010967b <do_fork+0x145>
    }

    proc->parent = current;
c010957d:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c0109583:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109586:	89 50 14             	mov    %edx,0x14(%eax)
    assert(current->wait_state == 0);
c0109589:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010958e:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109591:	85 c0                	test   %eax,%eax
c0109593:	74 19                	je     c01095ae <do_fork+0x78>
c0109595:	68 ea d5 10 c0       	push   $0xc010d5ea
c010959a:	68 03 d6 10 c0       	push   $0xc010d603
c010959f:	68 a3 01 00 00       	push   $0x1a3
c01095a4:	68 c1 d5 10 c0       	push   $0xc010d5c1
c01095a9:	e8 d8 77 ff ff       	call   c0100d86 <__panic>

    if ((ret = setup_kstack(proc)) != 0) {  //call the alloc_pages to alloc kstack space
c01095ae:	83 ec 0c             	sub    $0xc,%esp
c01095b1:	ff 75 f0             	pushl  -0x10(%ebp)
c01095b4:	e8 8f fc ff ff       	call   c0109248 <setup_kstack>
c01095b9:	83 c4 10             	add    $0x10,%esp
c01095bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01095bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01095c3:	74 15                	je     c01095da <do_fork+0xa4>
        cprintf("set_kstack() failed!");
c01095c5:	83 ec 0c             	sub    $0xc,%esp
c01095c8:	68 18 d6 10 c0       	push   $0xc010d618
c01095cd:	e8 76 6d ff ff       	call   c0100348 <cprintf>
c01095d2:	83 c4 10             	add    $0x10,%esp
        goto bad_fork_cleanup_proc;
c01095d5:	e9 a6 00 00 00       	jmp    c0109680 <do_fork+0x14a>
    }

    if (copy_mm(clone_flags, proc) != 0) {
c01095da:	83 ec 08             	sub    $0x8,%esp
c01095dd:	ff 75 f0             	pushl  -0x10(%ebp)
c01095e0:	ff 75 08             	pushl  0x8(%ebp)
c01095e3:	e8 8b fd ff ff       	call   c0109373 <copy_mm>
c01095e8:	83 c4 10             	add    $0x10,%esp
c01095eb:	85 c0                	test   %eax,%eax
c01095ed:	74 21                	je     c0109610 <do_fork+0xda>
        cprintf("copy_mm() failed!");
c01095ef:	83 ec 0c             	sub    $0xc,%esp
c01095f2:	68 2d d6 10 c0       	push   $0xc010d62d
c01095f7:	e8 4c 6d ff ff       	call   c0100348 <cprintf>
c01095fc:	83 c4 10             	add    $0x10,%esp
        goto bad_fork_cleanup_kstack;
c01095ff:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109600:	83 ec 0c             	sub    $0xc,%esp
c0109603:	ff 75 f0             	pushl  -0x10(%ebp)
c0109606:	e8 7d fc ff ff       	call   c0109288 <put_kstack>
c010960b:	83 c4 10             	add    $0x10,%esp
c010960e:	eb 70                	jmp    c0109680 <do_fork+0x14a>
    copy_thread(proc, stack, tf);
c0109610:	83 ec 04             	sub    $0x4,%esp
c0109613:	ff 75 10             	pushl  0x10(%ebp)
c0109616:	ff 75 0c             	pushl  0xc(%ebp)
c0109619:	ff 75 f0             	pushl  -0x10(%ebp)
c010961c:	e8 79 fe ff ff       	call   c010949a <copy_thread>
c0109621:	83 c4 10             	add    $0x10,%esp
    local_intr_save(intr_flag);
c0109624:	e8 f8 f5 ff ff       	call   c0108c21 <__intr_save>
c0109629:	89 45 ec             	mov    %eax,-0x14(%ebp)
        proc->pid = get_pid();
c010962c:	e8 fa f8 ff ff       	call   c0108f2b <get_pid>
c0109631:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109634:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c0109637:	83 ec 0c             	sub    $0xc,%esp
c010963a:	ff 75 f0             	pushl  -0x10(%ebp)
c010963d:	e8 7e fa ff ff       	call   c01090c0 <hash_proc>
c0109642:	83 c4 10             	add    $0x10,%esp
        set_links(proc);
c0109645:	83 ec 0c             	sub    $0xc,%esp
c0109648:	ff 75 f0             	pushl  -0x10(%ebp)
c010964b:	e8 ac f7 ff ff       	call   c0108dfc <set_links>
c0109650:	83 c4 10             	add    $0x10,%esp
    local_intr_restore(intr_flag);
c0109653:	83 ec 0c             	sub    $0xc,%esp
c0109656:	ff 75 ec             	pushl  -0x14(%ebp)
c0109659:	e8 ed f5 ff ff       	call   c0108c4b <__intr_restore>
c010965e:	83 c4 10             	add    $0x10,%esp
    wakeup_proc(proc);
c0109661:	83 ec 0c             	sub    $0xc,%esp
c0109664:	ff 75 f0             	pushl  -0x10(%ebp)
c0109667:	e8 1c 0f 00 00       	call   c010a588 <wakeup_proc>
c010966c:	83 c4 10             	add    $0x10,%esp
    ret = proc->pid;
c010966f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109672:	8b 40 04             	mov    0x4(%eax),%eax
c0109675:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109678:	eb 01                	jmp    c010967b <do_fork+0x145>
        goto fork_out;
c010967a:	90                   	nop
    return ret;
c010967b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010967e:	eb 10                	jmp    c0109690 <do_fork+0x15a>
bad_fork_cleanup_proc:
    kfree(proc);
c0109680:	83 ec 0c             	sub    $0xc,%esp
c0109683:	ff 75 f0             	pushl  -0x10(%ebp)
c0109686:	e8 bd b4 ff ff       	call   c0104b48 <kfree>
c010968b:	83 c4 10             	add    $0x10,%esp
    goto fork_out;
c010968e:	eb eb                	jmp    c010967b <do_fork+0x145>
}
c0109690:	c9                   	leave  
c0109691:	c3                   	ret    

c0109692 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109692:	55                   	push   %ebp
c0109693:	89 e5                	mov    %esp,%ebp
c0109695:	83 ec 18             	sub    $0x18,%esp
    if (current == idleproc) {
c0109698:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c010969e:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c01096a3:	39 c2                	cmp    %eax,%edx
c01096a5:	75 17                	jne    c01096be <do_exit+0x2c>
        panic("idleproc exit.\n");
c01096a7:	83 ec 04             	sub    $0x4,%esp
c01096aa:	68 3f d6 10 c0       	push   $0xc010d63f
c01096af:	68 ce 01 00 00       	push   $0x1ce
c01096b4:	68 c1 d5 10 c0       	push   $0xc010d5c1
c01096b9:	e8 c8 76 ff ff       	call   c0100d86 <__panic>
    }
    if (current == initproc) {
c01096be:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c01096c4:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c01096c9:	39 c2                	cmp    %eax,%edx
c01096cb:	75 17                	jne    c01096e4 <do_exit+0x52>
        panic("initproc exit.\n");
c01096cd:	83 ec 04             	sub    $0x4,%esp
c01096d0:	68 4f d6 10 c0       	push   $0xc010d64f
c01096d5:	68 d1 01 00 00       	push   $0x1d1
c01096da:	68 c1 d5 10 c0       	push   $0xc010d5c1
c01096df:	e8 a2 76 ff ff       	call   c0100d86 <__panic>
    }

    struct mm_struct *mm = current->mm;
c01096e4:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01096e9:	8b 40 18             	mov    0x18(%eax),%eax
c01096ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c01096ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01096f3:	74 57                	je     c010974c <do_exit+0xba>
        lcr3(boot_cr3);
c01096f5:	a1 a8 3f 1a c0       	mov    0xc01a3fa8,%eax
c01096fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01096fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109700:	0f 22 d8             	mov    %eax,%cr3
}
c0109703:	90                   	nop
        if (mm_count_dec(mm) == 0) {
c0109704:	83 ec 0c             	sub    $0xc,%esp
c0109707:	ff 75 f4             	pushl  -0xc(%ebp)
c010970a:	e8 d5 f5 ff ff       	call   c0108ce4 <mm_count_dec>
c010970f:	83 c4 10             	add    $0x10,%esp
c0109712:	85 c0                	test   %eax,%eax
c0109714:	75 2a                	jne    c0109740 <do_exit+0xae>
            exit_mmap(mm);
c0109716:	83 ec 0c             	sub    $0xc,%esp
c0109719:	ff 75 f4             	pushl  -0xc(%ebp)
c010971c:	e8 e7 e7 ff ff       	call   c0107f08 <exit_mmap>
c0109721:	83 c4 10             	add    $0x10,%esp
            put_pgdir(mm);
c0109724:	83 ec 0c             	sub    $0xc,%esp
c0109727:	ff 75 f4             	pushl  -0xc(%ebp)
c010972a:	e8 1b fc ff ff       	call   c010934a <put_pgdir>
c010972f:	83 c4 10             	add    $0x10,%esp
            mm_destroy(mm);
c0109732:	83 ec 0c             	sub    $0xc,%esp
c0109735:	ff 75 f4             	pushl  -0xc(%ebp)
c0109738:	e8 3b e5 ff ff       	call   c0107c78 <mm_destroy>
c010973d:	83 c4 10             	add    $0x10,%esp
        }
        current->mm = NULL;
c0109740:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109745:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010974c:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109751:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c0109757:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010975c:	8b 55 08             	mov    0x8(%ebp),%edx
c010975f:	89 50 68             	mov    %edx,0x68(%eax)

    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c0109762:	e8 ba f4 ff ff       	call   c0108c21 <__intr_save>
c0109767:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010976a:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010976f:	8b 40 14             	mov    0x14(%eax),%eax
c0109772:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c0109775:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109778:	8b 40 6c             	mov    0x6c(%eax),%eax
c010977b:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c0109780:	0f 85 9d 00 00 00    	jne    c0109823 <do_exit+0x191>
            wakeup_proc(proc);
c0109786:	83 ec 0c             	sub    $0xc,%esp
c0109789:	ff 75 ec             	pushl  -0x14(%ebp)
c010978c:	e8 f7 0d 00 00       	call   c010a588 <wakeup_proc>
c0109791:	83 c4 10             	add    $0x10,%esp
        }
        while (current->cptr != NULL) {
c0109794:	e9 8a 00 00 00       	jmp    c0109823 <do_exit+0x191>
            proc = current->cptr;
c0109799:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010979e:	8b 40 70             	mov    0x70(%eax),%eax
c01097a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c01097a4:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01097a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01097ac:	8b 52 78             	mov    0x78(%edx),%edx
c01097af:	89 50 70             	mov    %edx,0x70(%eax)

            proc->yptr = NULL;
c01097b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097b5:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c01097bc:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c01097c1:	8b 50 70             	mov    0x70(%eax),%edx
c01097c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097c7:	89 50 78             	mov    %edx,0x78(%eax)
c01097ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097cd:	8b 40 78             	mov    0x78(%eax),%eax
c01097d0:	85 c0                	test   %eax,%eax
c01097d2:	74 0e                	je     c01097e2 <do_exit+0x150>
                initproc->cptr->yptr = proc;
c01097d4:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c01097d9:	8b 40 70             	mov    0x70(%eax),%eax
c01097dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01097df:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c01097e2:	8b 15 2c 41 1a c0    	mov    0xc01a412c,%edx
c01097e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097eb:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c01097ee:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c01097f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01097f6:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c01097f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097fc:	8b 00                	mov    (%eax),%eax
c01097fe:	83 f8 03             	cmp    $0x3,%eax
c0109801:	75 20                	jne    c0109823 <do_exit+0x191>
                if (initproc->wait_state == WT_CHILD) {
c0109803:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c0109808:	8b 40 6c             	mov    0x6c(%eax),%eax
c010980b:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c0109810:	75 11                	jne    c0109823 <do_exit+0x191>
                    wakeup_proc(initproc);
c0109812:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c0109817:	83 ec 0c             	sub    $0xc,%esp
c010981a:	50                   	push   %eax
c010981b:	e8 68 0d 00 00       	call   c010a588 <wakeup_proc>
c0109820:	83 c4 10             	add    $0x10,%esp
        while (current->cptr != NULL) {
c0109823:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109828:	8b 40 70             	mov    0x70(%eax),%eax
c010982b:	85 c0                	test   %eax,%eax
c010982d:	0f 85 66 ff ff ff    	jne    c0109799 <do_exit+0x107>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c0109833:	83 ec 0c             	sub    $0xc,%esp
c0109836:	ff 75 f0             	pushl  -0x10(%ebp)
c0109839:	e8 0d f4 ff ff       	call   c0108c4b <__intr_restore>
c010983e:	83 c4 10             	add    $0x10,%esp

    schedule();
c0109841:	e8 b7 0d 00 00       	call   c010a5fd <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c0109846:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010984b:	8b 40 04             	mov    0x4(%eax),%eax
c010984e:	50                   	push   %eax
c010984f:	68 60 d6 10 c0       	push   $0xc010d660
c0109854:	68 fd 01 00 00       	push   $0x1fd
c0109859:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010985e:	e8 23 75 ff ff       	call   c0100d86 <__panic>

c0109863 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c0109863:	55                   	push   %ebp
c0109864:	89 e5                	mov    %esp,%ebp
c0109866:	83 ec 58             	sub    $0x58,%esp
    if (current->mm != NULL) {
c0109869:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010986e:	8b 40 18             	mov    0x18(%eax),%eax
c0109871:	85 c0                	test   %eax,%eax
c0109873:	74 17                	je     c010988c <load_icode+0x29>
        panic("load_icode: current->mm must be empty.\n");
c0109875:	83 ec 04             	sub    $0x4,%esp
c0109878:	68 80 d6 10 c0       	push   $0xc010d680
c010987d:	68 07 02 00 00       	push   $0x207
c0109882:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109887:	e8 fa 74 ff ff       	call   c0100d86 <__panic>
    }

    int ret = -E_NO_MEM;
c010988c:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c0109893:	e8 b3 e0 ff ff       	call   c010794b <mm_create>
c0109898:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010989b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010989f:	0f 84 a0 05 00 00    	je     c0109e45 <load_icode+0x5e2>
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c01098a5:	83 ec 0c             	sub    $0xc,%esp
c01098a8:	ff 75 d0             	pushl  -0x30(%ebp)
c01098ab:	e8 01 fa ff ff       	call   c01092b1 <setup_pgdir>
c01098b0:	83 c4 10             	add    $0x10,%esp
c01098b3:	85 c0                	test   %eax,%eax
c01098b5:	0f 85 79 05 00 00    	jne    c0109e34 <load_icode+0x5d1>
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c01098bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01098be:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c01098c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01098c4:	8b 50 1c             	mov    0x1c(%eax),%edx
c01098c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ca:	01 d0                	add    %edx,%eax
c01098cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c01098cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01098d2:	8b 00                	mov    (%eax),%eax
c01098d4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c01098d9:	74 0c                	je     c01098e7 <load_icode+0x84>
        ret = -E_INVAL_ELF;
c01098db:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c01098e2:	e9 3d 05 00 00       	jmp    c0109e24 <load_icode+0x5c1>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c01098e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01098ea:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01098ee:	0f b7 c0             	movzwl %ax,%eax
c01098f1:	c1 e0 05             	shl    $0x5,%eax
c01098f4:	89 c2                	mov    %eax,%edx
c01098f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01098f9:	01 d0                	add    %edx,%eax
c01098fb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph++) {
c01098fe:	e9 da 02 00 00       	jmp    c0109bdd <load_icode+0x37a>
        //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c0109903:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109906:	8b 00                	mov    (%eax),%eax
c0109908:	83 f8 01             	cmp    $0x1,%eax
c010990b:	0f 85 c1 02 00 00    	jne    c0109bd2 <load_icode+0x36f>
            continue;
        }
        if (ph->p_filesz > ph->p_memsz) {
c0109911:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109914:	8b 50 10             	mov    0x10(%eax),%edx
c0109917:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010991a:	8b 40 14             	mov    0x14(%eax),%eax
c010991d:	39 c2                	cmp    %eax,%edx
c010991f:	76 0c                	jbe    c010992d <load_icode+0xca>
            ret = -E_INVAL_ELF;
c0109921:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c0109928:	e9 e9 04 00 00       	jmp    c0109e16 <load_icode+0x5b3>
        }
        if (ph->p_filesz == 0) {
c010992d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109930:	8b 40 10             	mov    0x10(%eax),%eax
c0109933:	85 c0                	test   %eax,%eax
c0109935:	0f 84 9a 02 00 00    	je     c0109bd5 <load_icode+0x372>
            continue;
        }
        //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010993b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0109942:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X)
c0109949:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010994c:	8b 40 18             	mov    0x18(%eax),%eax
c010994f:	83 e0 01             	and    $0x1,%eax
c0109952:	85 c0                	test   %eax,%eax
c0109954:	74 04                	je     c010995a <load_icode+0xf7>
            vm_flags |= VM_EXEC;
c0109956:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W)
c010995a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010995d:	8b 40 18             	mov    0x18(%eax),%eax
c0109960:	83 e0 02             	and    $0x2,%eax
c0109963:	85 c0                	test   %eax,%eax
c0109965:	74 04                	je     c010996b <load_icode+0x108>
            vm_flags |= VM_WRITE;
c0109967:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R)
c010996b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010996e:	8b 40 18             	mov    0x18(%eax),%eax
c0109971:	83 e0 04             	and    $0x4,%eax
c0109974:	85 c0                	test   %eax,%eax
c0109976:	74 04                	je     c010997c <load_icode+0x119>
            vm_flags |= VM_READ;
c0109978:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE)
c010997c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010997f:	83 e0 02             	and    $0x2,%eax
c0109982:	85 c0                	test   %eax,%eax
c0109984:	74 04                	je     c010998a <load_icode+0x127>
            perm |= PTE_W;
c0109986:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010998a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010998d:	8b 50 14             	mov    0x14(%eax),%edx
c0109990:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109993:	8b 40 08             	mov    0x8(%eax),%eax
c0109996:	83 ec 0c             	sub    $0xc,%esp
c0109999:	6a 00                	push   $0x0
c010999b:	ff 75 e8             	pushl  -0x18(%ebp)
c010999e:	52                   	push   %edx
c010999f:	50                   	push   %eax
c01099a0:	ff 75 d0             	pushl  -0x30(%ebp)
c01099a3:	e8 71 e3 ff ff       	call   c0107d19 <mm_map>
c01099a8:	83 c4 20             	add    $0x20,%esp
c01099ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01099ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01099b2:	0f 85 54 04 00 00    	jne    c0109e0c <load_icode+0x5a9>
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
c01099b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099bb:	8b 50 04             	mov    0x4(%eax),%edx
c01099be:	8b 45 08             	mov    0x8(%ebp),%eax
c01099c1:	01 d0                	add    %edx,%eax
c01099c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c01099c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099c9:	8b 40 08             	mov    0x8(%eax),%eax
c01099cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01099cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01099d2:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01099d5:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01099d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01099dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c01099e0:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

        //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c01099e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099ea:	8b 50 08             	mov    0x8(%eax),%edx
c01099ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099f0:	8b 40 10             	mov    0x10(%eax),%eax
c01099f3:	01 d0                	add    %edx,%eax
c01099f5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c01099f8:	e9 82 00 00 00       	jmp    c0109a7f <load_icode+0x21c>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c01099fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109a00:	8b 40 0c             	mov    0xc(%eax),%eax
c0109a03:	83 ec 04             	sub    $0x4,%esp
c0109a06:	ff 75 e4             	pushl  -0x1c(%ebp)
c0109a09:	ff 75 d4             	pushl  -0x2c(%ebp)
c0109a0c:	50                   	push   %eax
c0109a0d:	e8 a3 c2 ff ff       	call   c0105cb5 <pgdir_alloc_page>
c0109a12:	83 c4 10             	add    $0x10,%esp
c0109a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109a1c:	0f 84 ed 03 00 00    	je     c0109e0f <load_icode+0x5ac>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c0109a22:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109a25:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c0109a28:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0109a2b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0109a30:	2b 45 b0             	sub    -0x50(%ebp),%eax
c0109a33:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0109a36:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c0109a3d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109a40:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0109a43:	73 09                	jae    c0109a4e <load_icode+0x1eb>
                size -= la - end;
c0109a45:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109a48:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c0109a4b:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c0109a4e:	83 ec 0c             	sub    $0xc,%esp
c0109a51:	ff 75 f0             	pushl  -0x10(%ebp)
c0109a54:	e8 44 f1 ff ff       	call   c0108b9d <page2kva>
c0109a59:	83 c4 10             	add    $0x10,%esp
c0109a5c:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0109a5f:	01 d0                	add    %edx,%eax
c0109a61:	83 ec 04             	sub    $0x4,%esp
c0109a64:	ff 75 dc             	pushl  -0x24(%ebp)
c0109a67:	ff 75 e0             	pushl  -0x20(%ebp)
c0109a6a:	50                   	push   %eax
c0109a6b:	e8 55 19 00 00       	call   c010b3c5 <memcpy>
c0109a70:	83 c4 10             	add    $0x10,%esp
            start += size, from += size;
c0109a73:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109a76:	01 45 d8             	add    %eax,-0x28(%ebp)
c0109a79:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109a7c:	01 45 e0             	add    %eax,-0x20(%ebp)
        while (start < end) {
c0109a7f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109a82:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c0109a85:	0f 82 72 ff ff ff    	jb     c01099fd <load_icode+0x19a>
        }

        //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c0109a8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a8e:	8b 50 08             	mov    0x8(%eax),%edx
c0109a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a94:	8b 40 14             	mov    0x14(%eax),%eax
c0109a97:	01 d0                	add    %edx,%eax
c0109a99:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        if (start < la) {
c0109a9c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109a9f:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0109aa2:	0f 83 1c 01 00 00    	jae    c0109bc4 <load_icode+0x361>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c0109aa8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109aab:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c0109aae:	0f 84 24 01 00 00    	je     c0109bd8 <load_icode+0x375>
                continue;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c0109ab4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109ab7:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c0109aba:	05 00 10 00 00       	add    $0x1000,%eax
c0109abf:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0109ac2:	b8 00 10 00 00       	mov    $0x1000,%eax
c0109ac7:	2b 45 b0             	sub    -0x50(%ebp),%eax
c0109aca:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c0109acd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109ad0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0109ad3:	73 09                	jae    c0109ade <load_icode+0x27b>
                size -= la - end;
c0109ad5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109ad8:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c0109adb:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c0109ade:	83 ec 0c             	sub    $0xc,%esp
c0109ae1:	ff 75 f0             	pushl  -0x10(%ebp)
c0109ae4:	e8 b4 f0 ff ff       	call   c0108b9d <page2kva>
c0109ae9:	83 c4 10             	add    $0x10,%esp
c0109aec:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0109aef:	01 d0                	add    %edx,%eax
c0109af1:	83 ec 04             	sub    $0x4,%esp
c0109af4:	ff 75 dc             	pushl  -0x24(%ebp)
c0109af7:	6a 00                	push   $0x0
c0109af9:	50                   	push   %eax
c0109afa:	e8 e5 17 00 00       	call   c010b2e4 <memset>
c0109aff:	83 c4 10             	add    $0x10,%esp
            start += size;
c0109b02:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109b05:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c0109b08:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109b0b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0109b0e:	73 0c                	jae    c0109b1c <load_icode+0x2b9>
c0109b10:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109b13:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c0109b16:	0f 84 a8 00 00 00    	je     c0109bc4 <load_icode+0x361>
c0109b1c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109b1f:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0109b22:	72 0c                	jb     c0109b30 <load_icode+0x2cd>
c0109b24:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109b27:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0109b2a:	0f 84 94 00 00 00    	je     c0109bc4 <load_icode+0x361>
c0109b30:	68 a8 d6 10 c0       	push   $0xc010d6a8
c0109b35:	68 03 d6 10 c0       	push   $0xc010d603
c0109b3a:	68 5d 02 00 00       	push   $0x25d
c0109b3f:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109b44:	e8 3d 72 ff ff       	call   c0100d86 <__panic>
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c0109b49:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109b4c:	8b 40 0c             	mov    0xc(%eax),%eax
c0109b4f:	83 ec 04             	sub    $0x4,%esp
c0109b52:	ff 75 e4             	pushl  -0x1c(%ebp)
c0109b55:	ff 75 d4             	pushl  -0x2c(%ebp)
c0109b58:	50                   	push   %eax
c0109b59:	e8 57 c1 ff ff       	call   c0105cb5 <pgdir_alloc_page>
c0109b5e:	83 c4 10             	add    $0x10,%esp
c0109b61:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109b68:	0f 84 a4 02 00 00    	je     c0109e12 <load_icode+0x5af>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c0109b6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109b71:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c0109b74:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0109b77:	b8 00 10 00 00       	mov    $0x1000,%eax
c0109b7c:	2b 45 b0             	sub    -0x50(%ebp),%eax
c0109b7f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0109b82:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c0109b89:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109b8c:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0109b8f:	73 09                	jae    c0109b9a <load_icode+0x337>
                size -= la - end;
c0109b91:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0109b94:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c0109b97:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c0109b9a:	83 ec 0c             	sub    $0xc,%esp
c0109b9d:	ff 75 f0             	pushl  -0x10(%ebp)
c0109ba0:	e8 f8 ef ff ff       	call   c0108b9d <page2kva>
c0109ba5:	83 c4 10             	add    $0x10,%esp
c0109ba8:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0109bab:	01 d0                	add    %edx,%eax
c0109bad:	83 ec 04             	sub    $0x4,%esp
c0109bb0:	ff 75 dc             	pushl  -0x24(%ebp)
c0109bb3:	6a 00                	push   $0x0
c0109bb5:	50                   	push   %eax
c0109bb6:	e8 29 17 00 00       	call   c010b2e4 <memset>
c0109bbb:	83 c4 10             	add    $0x10,%esp
            start += size;
c0109bbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109bc1:	01 45 d8             	add    %eax,-0x28(%ebp)
        while (start < end) {
c0109bc4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109bc7:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c0109bca:	0f 82 79 ff ff ff    	jb     c0109b49 <load_icode+0x2e6>
c0109bd0:	eb 07                	jmp    c0109bd9 <load_icode+0x376>
            continue;
c0109bd2:	90                   	nop
c0109bd3:	eb 04                	jmp    c0109bd9 <load_icode+0x376>
            continue;
c0109bd5:	90                   	nop
c0109bd6:	eb 01                	jmp    c0109bd9 <load_icode+0x376>
                continue;
c0109bd8:	90                   	nop
    for (; ph < ph_end; ph++) {
c0109bd9:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c0109bdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109be0:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0109be3:	0f 82 1a fd ff ff    	jb     c0109903 <load_icode+0xa0>
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c0109be9:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c0109bf0:	83 ec 0c             	sub    $0xc,%esp
c0109bf3:	6a 00                	push   $0x0
c0109bf5:	ff 75 e8             	pushl  -0x18(%ebp)
c0109bf8:	68 00 00 10 00       	push   $0x100000
c0109bfd:	68 00 00 f0 af       	push   $0xaff00000
c0109c02:	ff 75 d0             	pushl  -0x30(%ebp)
c0109c05:	e8 0f e1 ff ff       	call   c0107d19 <mm_map>
c0109c0a:	83 c4 20             	add    $0x20,%esp
c0109c0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c14:	0f 85 fb 01 00 00    	jne    c0109e15 <load_icode+0x5b2>
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
c0109c1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109c1d:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c20:	83 ec 04             	sub    $0x4,%esp
c0109c23:	6a 07                	push   $0x7
c0109c25:	68 00 f0 ff af       	push   $0xaffff000
c0109c2a:	50                   	push   %eax
c0109c2b:	e8 85 c0 ff ff       	call   c0105cb5 <pgdir_alloc_page>
c0109c30:	83 c4 10             	add    $0x10,%esp
c0109c33:	85 c0                	test   %eax,%eax
c0109c35:	75 19                	jne    c0109c50 <load_icode+0x3ed>
c0109c37:	68 e4 d6 10 c0       	push   $0xc010d6e4
c0109c3c:	68 03 d6 10 c0       	push   $0xc010d603
c0109c41:	68 70 02 00 00       	push   $0x270
c0109c46:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109c4b:	e8 36 71 ff ff       	call   c0100d86 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
c0109c50:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109c53:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c56:	83 ec 04             	sub    $0x4,%esp
c0109c59:	6a 07                	push   $0x7
c0109c5b:	68 00 e0 ff af       	push   $0xafffe000
c0109c60:	50                   	push   %eax
c0109c61:	e8 4f c0 ff ff       	call   c0105cb5 <pgdir_alloc_page>
c0109c66:	83 c4 10             	add    $0x10,%esp
c0109c69:	85 c0                	test   %eax,%eax
c0109c6b:	75 19                	jne    c0109c86 <load_icode+0x423>
c0109c6d:	68 28 d7 10 c0       	push   $0xc010d728
c0109c72:	68 03 d6 10 c0       	push   $0xc010d603
c0109c77:	68 71 02 00 00       	push   $0x271
c0109c7c:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109c81:	e8 00 71 ff ff       	call   c0100d86 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
c0109c86:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109c89:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c8c:	83 ec 04             	sub    $0x4,%esp
c0109c8f:	6a 07                	push   $0x7
c0109c91:	68 00 d0 ff af       	push   $0xafffd000
c0109c96:	50                   	push   %eax
c0109c97:	e8 19 c0 ff ff       	call   c0105cb5 <pgdir_alloc_page>
c0109c9c:	83 c4 10             	add    $0x10,%esp
c0109c9f:	85 c0                	test   %eax,%eax
c0109ca1:	75 19                	jne    c0109cbc <load_icode+0x459>
c0109ca3:	68 70 d7 10 c0       	push   $0xc010d770
c0109ca8:	68 03 d6 10 c0       	push   $0xc010d603
c0109cad:	68 72 02 00 00       	push   $0x272
c0109cb2:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109cb7:	e8 ca 70 ff ff       	call   c0100d86 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
c0109cbc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109cbf:	8b 40 0c             	mov    0xc(%eax),%eax
c0109cc2:	83 ec 04             	sub    $0x4,%esp
c0109cc5:	6a 07                	push   $0x7
c0109cc7:	68 00 c0 ff af       	push   $0xafffc000
c0109ccc:	50                   	push   %eax
c0109ccd:	e8 e3 bf ff ff       	call   c0105cb5 <pgdir_alloc_page>
c0109cd2:	83 c4 10             	add    $0x10,%esp
c0109cd5:	85 c0                	test   %eax,%eax
c0109cd7:	75 19                	jne    c0109cf2 <load_icode+0x48f>
c0109cd9:	68 b8 d7 10 c0       	push   $0xc010d7b8
c0109cde:	68 03 d6 10 c0       	push   $0xc010d603
c0109ce3:	68 73 02 00 00       	push   $0x273
c0109ce8:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109ced:	e8 94 70 ff ff       	call   c0100d86 <__panic>

    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c0109cf2:	83 ec 0c             	sub    $0xc,%esp
c0109cf5:	ff 75 d0             	pushl  -0x30(%ebp)
c0109cf8:	e8 cd ef ff ff       	call   c0108cca <mm_count_inc>
c0109cfd:	83 c4 10             	add    $0x10,%esp
    current->mm = mm;
c0109d00:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109d05:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0109d08:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c0109d0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109d0e:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d11:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0109d14:	81 7d c4 ff ff ff bf 	cmpl   $0xbfffffff,-0x3c(%ebp)
c0109d1b:	77 17                	ja     c0109d34 <load_icode+0x4d1>
c0109d1d:	ff 75 c4             	pushl  -0x3c(%ebp)
c0109d20:	68 7c d5 10 c0       	push   $0xc010d57c
c0109d25:	68 78 02 00 00       	push   $0x278
c0109d2a:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109d2f:	e8 52 70 ff ff       	call   c0100d86 <__panic>
c0109d34:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0109d37:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109d3d:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109d42:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c0109d45:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109d48:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d4b:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0109d4e:	81 7d c0 ff ff ff bf 	cmpl   $0xbfffffff,-0x40(%ebp)
c0109d55:	77 17                	ja     c0109d6e <load_icode+0x50b>
c0109d57:	ff 75 c0             	pushl  -0x40(%ebp)
c0109d5a:	68 7c d5 10 c0       	push   $0xc010d57c
c0109d5f:	68 79 02 00 00       	push   $0x279
c0109d64:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109d69:	e8 18 70 ff ff       	call   c0100d86 <__panic>
c0109d6e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0109d71:	05 00 00 00 40       	add    $0x40000000,%eax
c0109d76:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109d79:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0109d7c:	0f 22 d8             	mov    %eax,%cr3
}
c0109d7f:	90                   	nop

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c0109d80:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109d85:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109d88:	89 45 bc             	mov    %eax,-0x44(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c0109d8b:	83 ec 04             	sub    $0x4,%esp
c0109d8e:	6a 4c                	push   $0x4c
c0109d90:	6a 00                	push   $0x0
c0109d92:	ff 75 bc             	pushl  -0x44(%ebp)
c0109d95:	e8 4a 15 00 00       	call   c010b2e4 <memset>
c0109d9a:	83 c4 10             	add    $0x10,%esp
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c0109d9d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109da0:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_fs = tf->tf_ss = USER_DS;
c0109da6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109da9:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c0109daf:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109db2:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c0109db6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109db9:	66 89 50 24          	mov    %dx,0x24(%eax)
c0109dbd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109dc0:	0f b7 50 24          	movzwl 0x24(%eax),%edx
c0109dc4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109dc7:	66 89 50 28          	mov    %dx,0x28(%eax)
c0109dcb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109dce:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0109dd2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109dd5:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c0109dd9:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109ddc:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eflags |= FL_IF;
c0109de3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109de6:	8b 40 40             	mov    0x40(%eax),%eax
c0109de9:	80 cc 02             	or     $0x2,%ah
c0109dec:	89 c2                	mov    %eax,%edx
c0109dee:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109df1:	89 50 40             	mov    %edx,0x40(%eax)
    tf->tf_eip= elf->e_entry;
c0109df4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0109df7:	8b 50 18             	mov    0x18(%eax),%edx
c0109dfa:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109dfd:	89 50 38             	mov    %edx,0x38(%eax)
    ret = 0;
c0109e00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c0109e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e0a:	eb 3c                	jmp    c0109e48 <load_icode+0x5e5>
            goto bad_cleanup_mmap;
c0109e0c:	90                   	nop
c0109e0d:	eb 07                	jmp    c0109e16 <load_icode+0x5b3>
                goto bad_cleanup_mmap;
c0109e0f:	90                   	nop
c0109e10:	eb 04                	jmp    c0109e16 <load_icode+0x5b3>
                goto bad_cleanup_mmap;
c0109e12:	90                   	nop
c0109e13:	eb 01                	jmp    c0109e16 <load_icode+0x5b3>
        goto bad_cleanup_mmap;
c0109e15:	90                   	nop
bad_cleanup_mmap:
    exit_mmap(mm);
c0109e16:	83 ec 0c             	sub    $0xc,%esp
c0109e19:	ff 75 d0             	pushl  -0x30(%ebp)
c0109e1c:	e8 e7 e0 ff ff       	call   c0107f08 <exit_mmap>
c0109e21:	83 c4 10             	add    $0x10,%esp
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c0109e24:	83 ec 0c             	sub    $0xc,%esp
c0109e27:	ff 75 d0             	pushl  -0x30(%ebp)
c0109e2a:	e8 1b f5 ff ff       	call   c010934a <put_pgdir>
c0109e2f:	83 c4 10             	add    $0x10,%esp
c0109e32:	eb 01                	jmp    c0109e35 <load_icode+0x5d2>
        goto bad_pgdir_cleanup_mm;
c0109e34:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109e35:	83 ec 0c             	sub    $0xc,%esp
c0109e38:	ff 75 d0             	pushl  -0x30(%ebp)
c0109e3b:	e8 38 de ff ff       	call   c0107c78 <mm_destroy>
c0109e40:	83 c4 10             	add    $0x10,%esp
bad_mm:
    goto out;
c0109e43:	eb c2                	jmp    c0109e07 <load_icode+0x5a4>
        goto bad_mm;
c0109e45:	90                   	nop
    goto out;
c0109e46:	eb bf                	jmp    c0109e07 <load_icode+0x5a4>
}
c0109e48:	c9                   	leave  
c0109e49:	c3                   	ret    

c0109e4a <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c0109e4a:	55                   	push   %ebp
c0109e4b:	89 e5                	mov    %esp,%ebp
c0109e4d:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c0109e50:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109e55:	8b 40 18             	mov    0x18(%eax),%eax
c0109e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c0109e5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e5e:	6a 00                	push   $0x0
c0109e60:	ff 75 0c             	pushl  0xc(%ebp)
c0109e63:	50                   	push   %eax
c0109e64:	ff 75 f4             	pushl  -0xc(%ebp)
c0109e67:	e8 07 ea ff ff       	call   c0108873 <user_mem_check>
c0109e6c:	83 c4 10             	add    $0x10,%esp
c0109e6f:	85 c0                	test   %eax,%eax
c0109e71:	75 0a                	jne    c0109e7d <do_execve+0x33>
        return -E_INVAL;
c0109e73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109e78:	e9 ee 00 00 00       	jmp    c0109f6b <do_execve+0x121>
    }
    if (len > PROC_NAME_LEN) {
c0109e7d:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c0109e81:	76 07                	jbe    c0109e8a <do_execve+0x40>
        len = PROC_NAME_LEN;
c0109e83:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c0109e8a:	83 ec 04             	sub    $0x4,%esp
c0109e8d:	6a 10                	push   $0x10
c0109e8f:	6a 00                	push   $0x0
c0109e91:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0109e94:	50                   	push   %eax
c0109e95:	e8 4a 14 00 00       	call   c010b2e4 <memset>
c0109e9a:	83 c4 10             	add    $0x10,%esp
    memcpy(local_name, name, len);
c0109e9d:	83 ec 04             	sub    $0x4,%esp
c0109ea0:	ff 75 0c             	pushl  0xc(%ebp)
c0109ea3:	ff 75 08             	pushl  0x8(%ebp)
c0109ea6:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0109ea9:	50                   	push   %eax
c0109eaa:	e8 16 15 00 00       	call   c010b3c5 <memcpy>
c0109eaf:	83 c4 10             	add    $0x10,%esp

    if (mm != NULL) {
c0109eb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109eb6:	74 57                	je     c0109f0f <do_execve+0xc5>
        lcr3(boot_cr3);
c0109eb8:	a1 a8 3f 1a c0       	mov    0xc01a3fa8,%eax
c0109ebd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109ec0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ec3:	0f 22 d8             	mov    %eax,%cr3
}
c0109ec6:	90                   	nop
        if (mm_count_dec(mm) == 0) {
c0109ec7:	83 ec 0c             	sub    $0xc,%esp
c0109eca:	ff 75 f4             	pushl  -0xc(%ebp)
c0109ecd:	e8 12 ee ff ff       	call   c0108ce4 <mm_count_dec>
c0109ed2:	83 c4 10             	add    $0x10,%esp
c0109ed5:	85 c0                	test   %eax,%eax
c0109ed7:	75 2a                	jne    c0109f03 <do_execve+0xb9>
            exit_mmap(mm);
c0109ed9:	83 ec 0c             	sub    $0xc,%esp
c0109edc:	ff 75 f4             	pushl  -0xc(%ebp)
c0109edf:	e8 24 e0 ff ff       	call   c0107f08 <exit_mmap>
c0109ee4:	83 c4 10             	add    $0x10,%esp
            put_pgdir(mm);
c0109ee7:	83 ec 0c             	sub    $0xc,%esp
c0109eea:	ff 75 f4             	pushl  -0xc(%ebp)
c0109eed:	e8 58 f4 ff ff       	call   c010934a <put_pgdir>
c0109ef2:	83 c4 10             	add    $0x10,%esp
            mm_destroy(mm);
c0109ef5:	83 ec 0c             	sub    $0xc,%esp
c0109ef8:	ff 75 f4             	pushl  -0xc(%ebp)
c0109efb:	e8 78 dd ff ff       	call   c0107c78 <mm_destroy>
c0109f00:	83 c4 10             	add    $0x10,%esp
        }
        current->mm = NULL;
c0109f03:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109f08:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c0109f0f:	83 ec 08             	sub    $0x8,%esp
c0109f12:	ff 75 14             	pushl  0x14(%ebp)
c0109f15:	ff 75 10             	pushl  0x10(%ebp)
c0109f18:	e8 46 f9 ff ff       	call   c0109863 <load_icode>
c0109f1d:	83 c4 10             	add    $0x10,%esp
c0109f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109f23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109f27:	75 1c                	jne    c0109f45 <do_execve+0xfb>
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c0109f29:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109f2e:	83 ec 08             	sub    $0x8,%esp
c0109f31:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0109f34:	52                   	push   %edx
c0109f35:	50                   	push   %eax
c0109f36:	e8 57 ee ff ff       	call   c0108d92 <set_proc_name>
c0109f3b:	83 c4 10             	add    $0x10,%esp
    return 0;
c0109f3e:	b8 00 00 00 00       	mov    $0x0,%eax
c0109f43:	eb 26                	jmp    c0109f6b <do_execve+0x121>
        goto execve_exit;
c0109f45:	90                   	nop

execve_exit:
    do_exit(ret);
c0109f46:	83 ec 0c             	sub    $0xc,%esp
c0109f49:	ff 75 f0             	pushl  -0x10(%ebp)
c0109f4c:	e8 41 f7 ff ff       	call   c0109692 <do_exit>
c0109f51:	83 c4 10             	add    $0x10,%esp
    panic("already exit: %e.\n", ret);
c0109f54:	ff 75 f0             	pushl  -0x10(%ebp)
c0109f57:	68 fe d7 10 c0       	push   $0xc010d7fe
c0109f5c:	68 bb 02 00 00       	push   $0x2bb
c0109f61:	68 c1 d5 10 c0       	push   $0xc010d5c1
c0109f66:	e8 1b 6e ff ff       	call   c0100d86 <__panic>
}
c0109f6b:	c9                   	leave  
c0109f6c:	c3                   	ret    

c0109f6d <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c0109f6d:	55                   	push   %ebp
c0109f6e:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c0109f70:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109f75:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c0109f7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109f81:	5d                   	pop    %ebp
c0109f82:	c3                   	ret    

c0109f83 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c0109f83:	55                   	push   %ebp
c0109f84:	89 e5                	mov    %esp,%ebp
c0109f86:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = current->mm;
c0109f89:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109f8e:	8b 40 18             	mov    0x18(%eax),%eax
c0109f91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c0109f94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109f98:	74 21                	je     c0109fbb <do_wait+0x38>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c0109f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f9d:	6a 01                	push   $0x1
c0109f9f:	6a 04                	push   $0x4
c0109fa1:	50                   	push   %eax
c0109fa2:	ff 75 ec             	pushl  -0x14(%ebp)
c0109fa5:	e8 c9 e8 ff ff       	call   c0108873 <user_mem_check>
c0109faa:	83 c4 10             	add    $0x10,%esp
c0109fad:	85 c0                	test   %eax,%eax
c0109faf:	75 0a                	jne    c0109fbb <do_wait+0x38>
            return -E_INVAL;
c0109fb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109fb6:	e9 55 01 00 00       	jmp    c010a110 <do_wait+0x18d>
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
c0109fbb:	90                   	nop
    haskid = 0;
c0109fbc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c0109fc3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109fc7:	74 39                	je     c010a002 <do_wait+0x7f>
        proc = find_proc(pid);
c0109fc9:	83 ec 0c             	sub    $0xc,%esp
c0109fcc:	ff 75 08             	pushl  0x8(%ebp)
c0109fcf:	e8 9f f1 ff ff       	call   c0109173 <find_proc>
c0109fd4:	83 c4 10             	add    $0x10,%esp
c0109fd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c0109fda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109fde:	74 4f                	je     c010a02f <do_wait+0xac>
c0109fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fe3:	8b 50 14             	mov    0x14(%eax),%edx
c0109fe6:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109feb:	39 c2                	cmp    %eax,%edx
c0109fed:	75 40                	jne    c010a02f <do_wait+0xac>
            haskid = 1;
c0109fef:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c0109ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ff9:	8b 00                	mov    (%eax),%eax
c0109ffb:	83 f8 03             	cmp    $0x3,%eax
c0109ffe:	75 2f                	jne    c010a02f <do_wait+0xac>
                goto found;
c010a000:	eb 7f                	jmp    c010a081 <do_wait+0xfe>
            }
        }
    } else {
        proc = current->cptr;
c010a002:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a007:	8b 40 70             	mov    0x70(%eax),%eax
c010a00a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010a00d:	eb 1a                	jmp    c010a029 <do_wait+0xa6>
            haskid = 1;
c010a00f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a016:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a019:	8b 00                	mov    (%eax),%eax
c010a01b:	83 f8 03             	cmp    $0x3,%eax
c010a01e:	74 60                	je     c010a080 <do_wait+0xfd>
        for (; proc != NULL; proc = proc->optr) {
c010a020:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a023:	8b 40 78             	mov    0x78(%eax),%eax
c010a026:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a029:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a02d:	75 e0                	jne    c010a00f <do_wait+0x8c>
                goto found;
            }
        }
    }
    if (haskid) {
c010a02f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a033:	74 41                	je     c010a076 <do_wait+0xf3>
        current->state = PROC_SLEEPING;
c010a035:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a03a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010a040:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a045:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010a04c:	e8 ac 05 00 00       	call   c010a5fd <schedule>
        if (current->flags & PF_EXITING) {
c010a051:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a056:	8b 40 44             	mov    0x44(%eax),%eax
c010a059:	83 e0 01             	and    $0x1,%eax
c010a05c:	85 c0                	test   %eax,%eax
c010a05e:	0f 84 58 ff ff ff    	je     c0109fbc <do_wait+0x39>
            do_exit(-E_KILLED);
c010a064:	83 ec 0c             	sub    $0xc,%esp
c010a067:	6a f7                	push   $0xfffffff7
c010a069:	e8 24 f6 ff ff       	call   c0109692 <do_exit>
c010a06e:	83 c4 10             	add    $0x10,%esp
        }
        goto repeat;
c010a071:	e9 46 ff ff ff       	jmp    c0109fbc <do_wait+0x39>
    }
    return -E_BAD_PROC;
c010a076:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010a07b:	e9 90 00 00 00       	jmp    c010a110 <do_wait+0x18d>
                goto found;
c010a080:	90                   	nop

found:
    if (proc == idleproc || proc == initproc) {
c010a081:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a086:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a089:	74 0a                	je     c010a095 <do_wait+0x112>
c010a08b:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a090:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a093:	75 17                	jne    c010a0ac <do_wait+0x129>
        panic("wait idleproc or initproc.\n");
c010a095:	83 ec 04             	sub    $0x4,%esp
c010a098:	68 11 d8 10 c0       	push   $0xc010d811
c010a09d:	68 f3 02 00 00       	push   $0x2f3
c010a0a2:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a0a7:	e8 da 6c ff ff       	call   c0100d86 <__panic>
    }
    if (code_store != NULL) {
c010a0ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a0b0:	74 0b                	je     c010a0bd <do_wait+0x13a>
        *code_store = proc->exit_code;
c010a0b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0b5:	8b 50 68             	mov    0x68(%eax),%edx
c010a0b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a0bb:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010a0bd:	e8 5f eb ff ff       	call   c0108c21 <__intr_save>
c010a0c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010a0c5:	83 ec 0c             	sub    $0xc,%esp
c010a0c8:	ff 75 f4             	pushl  -0xc(%ebp)
c010a0cb:	e8 6d f0 ff ff       	call   c010913d <unhash_proc>
c010a0d0:	83 c4 10             	add    $0x10,%esp
        remove_links(proc);
c010a0d3:	83 ec 0c             	sub    $0xc,%esp
c010a0d6:	ff 75 f4             	pushl  -0xc(%ebp)
c010a0d9:	e8 c7 ed ff ff       	call   c0108ea5 <remove_links>
c010a0de:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c010a0e1:	83 ec 0c             	sub    $0xc,%esp
c010a0e4:	ff 75 e8             	pushl  -0x18(%ebp)
c010a0e7:	e8 5f eb ff ff       	call   c0108c4b <__intr_restore>
c010a0ec:	83 c4 10             	add    $0x10,%esp
    put_kstack(proc);
c010a0ef:	83 ec 0c             	sub    $0xc,%esp
c010a0f2:	ff 75 f4             	pushl  -0xc(%ebp)
c010a0f5:	e8 8e f1 ff ff       	call   c0109288 <put_kstack>
c010a0fa:	83 c4 10             	add    $0x10,%esp
    kfree(proc);
c010a0fd:	83 ec 0c             	sub    $0xc,%esp
c010a100:	ff 75 f4             	pushl  -0xc(%ebp)
c010a103:	e8 40 aa ff ff       	call   c0104b48 <kfree>
c010a108:	83 c4 10             	add    $0x10,%esp
    return 0;
c010a10b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a110:	c9                   	leave  
c010a111:	c3                   	ret    

c010a112 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010a112:	55                   	push   %ebp
c010a113:	89 e5                	mov    %esp,%ebp
c010a115:	83 ec 18             	sub    $0x18,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010a118:	83 ec 0c             	sub    $0xc,%esp
c010a11b:	ff 75 08             	pushl  0x8(%ebp)
c010a11e:	e8 50 f0 ff ff       	call   c0109173 <find_proc>
c010a123:	83 c4 10             	add    $0x10,%esp
c010a126:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a129:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a12d:	74 44                	je     c010a173 <do_kill+0x61>
        if (!(proc->flags & PF_EXITING)) {
c010a12f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a132:	8b 40 44             	mov    0x44(%eax),%eax
c010a135:	83 e0 01             	and    $0x1,%eax
c010a138:	85 c0                	test   %eax,%eax
c010a13a:	75 30                	jne    c010a16c <do_kill+0x5a>
            proc->flags |= PF_EXITING;
c010a13c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a13f:	8b 40 44             	mov    0x44(%eax),%eax
c010a142:	83 c8 01             	or     $0x1,%eax
c010a145:	89 c2                	mov    %eax,%edx
c010a147:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a14a:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010a14d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a150:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a153:	85 c0                	test   %eax,%eax
c010a155:	79 0e                	jns    c010a165 <do_kill+0x53>
                wakeup_proc(proc);
c010a157:	83 ec 0c             	sub    $0xc,%esp
c010a15a:	ff 75 f4             	pushl  -0xc(%ebp)
c010a15d:	e8 26 04 00 00       	call   c010a588 <wakeup_proc>
c010a162:	83 c4 10             	add    $0x10,%esp
            }
            return 0;
c010a165:	b8 00 00 00 00       	mov    $0x0,%eax
c010a16a:	eb 0c                	jmp    c010a178 <do_kill+0x66>
        }
        return -E_KILLED;
c010a16c:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010a171:	eb 05                	jmp    c010a178 <do_kill+0x66>
    }
    return -E_INVAL;
c010a173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010a178:	c9                   	leave  
c010a179:	c3                   	ret    

c010a17a <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010a17a:	55                   	push   %ebp
c010a17b:	89 e5                	mov    %esp,%ebp
c010a17d:	57                   	push   %edi
c010a17e:	56                   	push   %esi
c010a17f:	53                   	push   %ebx
c010a180:	83 ec 1c             	sub    $0x1c,%esp
    int ret, len = strlen(name);
c010a183:	83 ec 0c             	sub    $0xc,%esp
c010a186:	ff 75 08             	pushl  0x8(%ebp)
c010a189:	e8 27 0e 00 00       	call   c010afb5 <strlen>
c010a18e:	83 c4 10             	add    $0x10,%esp
c010a191:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile(
c010a194:	b8 04 00 00 00       	mov    $0x4,%eax
c010a199:	8b 55 08             	mov    0x8(%ebp),%edx
c010a19c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010a19f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010a1a2:	8b 75 10             	mov    0x10(%ebp),%esi
c010a1a5:	89 f7                	mov    %esi,%edi
c010a1a7:	cd 80                	int    $0x80
c010a1a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a"(ret)
        : "i"(T_SYSCALL), "0"(SYS_exec), "d"(name), "c"(len), "b"(binary), "D"(size)
        : "memory");
    return ret;
c010a1ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010a1af:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010a1b2:	5b                   	pop    %ebx
c010a1b3:	5e                   	pop    %esi
c010a1b4:	5f                   	pop    %edi
c010a1b5:	5d                   	pop    %ebp
c010a1b6:	c3                   	ret    

c010a1b7 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010a1b7:	55                   	push   %ebp
c010a1b8:	89 e5                	mov    %esp,%ebp
c010a1ba:	83 ec 08             	sub    $0x8,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
c010a1bd:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a1c2:	8b 40 04             	mov    0x4(%eax),%eax
c010a1c5:	83 ec 04             	sub    $0x4,%esp
c010a1c8:	68 2d d8 10 c0       	push   $0xc010d82d
c010a1cd:	50                   	push   %eax
c010a1ce:	68 34 d8 10 c0       	push   $0xc010d834
c010a1d3:	e8 70 61 ff ff       	call   c0100348 <cprintf>
c010a1d8:	83 c4 10             	add    $0x10,%esp
c010a1db:	b8 70 78 00 00       	mov    $0x7870,%eax
c010a1e0:	83 ec 04             	sub    $0x4,%esp
c010a1e3:	50                   	push   %eax
c010a1e4:	68 84 64 14 c0       	push   $0xc0146484
c010a1e9:	68 2d d8 10 c0       	push   $0xc010d82d
c010a1ee:	e8 87 ff ff ff       	call   c010a17a <kernel_execve>
c010a1f3:	83 c4 10             	add    $0x10,%esp
#endif
    panic("user_main execve failed.\n");
c010a1f6:	83 ec 04             	sub    $0x4,%esp
c010a1f9:	68 5b d8 10 c0       	push   $0xc010d85b
c010a1fe:	68 3c 03 00 00       	push   $0x33c
c010a203:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a208:	e8 79 6b ff ff       	call   c0100d86 <__panic>

c010a20d <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010a20d:	55                   	push   %ebp
c010a20e:	89 e5                	mov    %esp,%ebp
c010a210:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010a213:	e8 2c ae ff ff       	call   c0105044 <nr_free_pages>
c010a218:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010a21b:	e8 f7 a7 ff ff       	call   c0104a17 <kallocated>
c010a220:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010a223:	83 ec 04             	sub    $0x4,%esp
c010a226:	6a 00                	push   $0x0
c010a228:	6a 00                	push   $0x0
c010a22a:	68 b7 a1 10 c0       	push   $0xc010a1b7
c010a22f:	e8 af ef ff ff       	call   c01091e3 <kernel_thread>
c010a234:	83 c4 10             	add    $0x10,%esp
c010a237:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010a23a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010a23e:	7f 1c                	jg     c010a25c <init_main+0x4f>
        panic("create user_main failed.\n");
c010a240:	83 ec 04             	sub    $0x4,%esp
c010a243:	68 75 d8 10 c0       	push   $0xc010d875
c010a248:	68 47 03 00 00       	push   $0x347
c010a24d:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a252:	e8 2f 6b ff ff       	call   c0100d86 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
c010a257:	e8 a1 03 00 00       	call   c010a5fd <schedule>
    while (do_wait(0, NULL) == 0) {
c010a25c:	83 ec 08             	sub    $0x8,%esp
c010a25f:	6a 00                	push   $0x0
c010a261:	6a 00                	push   $0x0
c010a263:	e8 1b fd ff ff       	call   c0109f83 <do_wait>
c010a268:	83 c4 10             	add    $0x10,%esp
c010a26b:	85 c0                	test   %eax,%eax
c010a26d:	74 e8                	je     c010a257 <init_main+0x4a>
    }

    cprintf("all user-mode processes have quit.\n");
c010a26f:	83 ec 0c             	sub    $0xc,%esp
c010a272:	68 90 d8 10 c0       	push   $0xc010d890
c010a277:	e8 cc 60 ff ff       	call   c0100348 <cprintf>
c010a27c:	83 c4 10             	add    $0x10,%esp
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010a27f:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a284:	8b 40 70             	mov    0x70(%eax),%eax
c010a287:	85 c0                	test   %eax,%eax
c010a289:	75 18                	jne    c010a2a3 <init_main+0x96>
c010a28b:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a290:	8b 40 74             	mov    0x74(%eax),%eax
c010a293:	85 c0                	test   %eax,%eax
c010a295:	75 0c                	jne    c010a2a3 <init_main+0x96>
c010a297:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a29c:	8b 40 78             	mov    0x78(%eax),%eax
c010a29f:	85 c0                	test   %eax,%eax
c010a2a1:	74 19                	je     c010a2bc <init_main+0xaf>
c010a2a3:	68 b4 d8 10 c0       	push   $0xc010d8b4
c010a2a8:	68 03 d6 10 c0       	push   $0xc010d603
c010a2ad:	68 4f 03 00 00       	push   $0x34f
c010a2b2:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a2b7:	e8 ca 6a ff ff       	call   c0100d86 <__panic>
    assert(nr_process == 2);
c010a2bc:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c010a2c1:	83 f8 02             	cmp    $0x2,%eax
c010a2c4:	74 19                	je     c010a2df <init_main+0xd2>
c010a2c6:	68 ff d8 10 c0       	push   $0xc010d8ff
c010a2cb:	68 03 d6 10 c0       	push   $0xc010d603
c010a2d0:	68 50 03 00 00       	push   $0x350
c010a2d5:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a2da:	e8 a7 6a ff ff       	call   c0100d86 <__panic>
c010a2df:	c7 45 e8 20 41 1a c0 	movl   $0xc01a4120,-0x18(%ebp)
c010a2e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a2e9:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010a2ec:	8b 15 2c 41 1a c0    	mov    0xc01a412c,%edx
c010a2f2:	83 c2 58             	add    $0x58,%edx
c010a2f5:	39 d0                	cmp    %edx,%eax
c010a2f7:	74 19                	je     c010a312 <init_main+0x105>
c010a2f9:	68 10 d9 10 c0       	push   $0xc010d910
c010a2fe:	68 03 d6 10 c0       	push   $0xc010d603
c010a303:	68 51 03 00 00       	push   $0x351
c010a308:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a30d:	e8 74 6a ff ff       	call   c0100d86 <__panic>
c010a312:	c7 45 e4 20 41 1a c0 	movl   $0xc01a4120,-0x1c(%ebp)
    return listelm->prev;
c010a319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a31c:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010a31e:	8b 15 2c 41 1a c0    	mov    0xc01a412c,%edx
c010a324:	83 c2 58             	add    $0x58,%edx
c010a327:	39 d0                	cmp    %edx,%eax
c010a329:	74 19                	je     c010a344 <init_main+0x137>
c010a32b:	68 40 d9 10 c0       	push   $0xc010d940
c010a330:	68 03 d6 10 c0       	push   $0xc010d603
c010a335:	68 52 03 00 00       	push   $0x352
c010a33a:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a33f:	e8 42 6a ff ff       	call   c0100d86 <__panic>

    cprintf("init check memory pass.\n");
c010a344:	83 ec 0c             	sub    $0xc,%esp
c010a347:	68 70 d9 10 c0       	push   $0xc010d970
c010a34c:	e8 f7 5f ff ff       	call   c0100348 <cprintf>
c010a351:	83 c4 10             	add    $0x10,%esp
    return 0;
c010a354:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a359:	c9                   	leave  
c010a35a:	c3                   	ret    

c010a35b <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void
proc_init(void) {
c010a35b:	55                   	push   %ebp
c010a35c:	89 e5                	mov    %esp,%ebp
c010a35e:	83 ec 18             	sub    $0x18,%esp
c010a361:	c7 45 ec 20 41 1a c0 	movl   $0xc01a4120,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010a368:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a36b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a36e:	89 50 04             	mov    %edx,0x4(%eax)
c010a371:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a374:	8b 50 04             	mov    0x4(%eax),%edx
c010a377:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a37a:	89 10                	mov    %edx,(%eax)
}
c010a37c:	90                   	nop
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++) {
c010a37d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010a384:	eb 27                	jmp    c010a3ad <proc_init+0x52>
        list_init(hash_list + i);
c010a386:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a389:	c1 e0 03             	shl    $0x3,%eax
c010a38c:	05 40 41 1a c0       	add    $0xc01a4140,%eax
c010a391:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c010a394:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a397:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010a39a:	89 50 04             	mov    %edx,0x4(%eax)
c010a39d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a3a0:	8b 50 04             	mov    0x4(%eax),%edx
c010a3a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a3a6:	89 10                	mov    %edx,(%eax)
}
c010a3a8:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i++) {
c010a3a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010a3ad:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010a3b4:	7e d0                	jle    c010a386 <proc_init+0x2b>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010a3b6:	e8 85 e9 ff ff       	call   c0108d40 <alloc_proc>
c010a3bb:	a3 28 41 1a c0       	mov    %eax,0xc01a4128
c010a3c0:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a3c5:	85 c0                	test   %eax,%eax
c010a3c7:	75 17                	jne    c010a3e0 <proc_init+0x85>
        panic("cannot alloc idleproc.\n");
c010a3c9:	83 ec 04             	sub    $0x4,%esp
c010a3cc:	68 89 d9 10 c0       	push   $0xc010d989
c010a3d1:	68 64 03 00 00       	push   $0x364
c010a3d6:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a3db:	e8 a6 69 ff ff       	call   c0100d86 <__panic>
    }

    idleproc->pid = 0;
c010a3e0:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a3e5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010a3ec:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a3f1:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010a3f7:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a3fc:	ba 00 d0 12 c0       	mov    $0xc012d000,%edx
c010a401:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010a404:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a409:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010a410:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a415:	83 ec 08             	sub    $0x8,%esp
c010a418:	68 a1 d9 10 c0       	push   $0xc010d9a1
c010a41d:	50                   	push   %eax
c010a41e:	e8 6f e9 ff ff       	call   c0108d92 <set_proc_name>
c010a423:	83 c4 10             	add    $0x10,%esp
    nr_process++;
c010a426:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c010a42b:	83 c0 01             	add    $0x1,%eax
c010a42e:	a3 40 61 1a c0       	mov    %eax,0xc01a6140

    current = idleproc;
c010a433:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a438:	a3 30 41 1a c0       	mov    %eax,0xc01a4130

    int pid = kernel_thread(init_main, NULL, 0);
c010a43d:	83 ec 04             	sub    $0x4,%esp
c010a440:	6a 00                	push   $0x0
c010a442:	6a 00                	push   $0x0
c010a444:	68 0d a2 10 c0       	push   $0xc010a20d
c010a449:	e8 95 ed ff ff       	call   c01091e3 <kernel_thread>
c010a44e:	83 c4 10             	add    $0x10,%esp
c010a451:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010a454:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a458:	7f 17                	jg     c010a471 <proc_init+0x116>
        panic("create init_main failed.\n");
c010a45a:	83 ec 04             	sub    $0x4,%esp
c010a45d:	68 a6 d9 10 c0       	push   $0xc010d9a6
c010a462:	68 72 03 00 00       	push   $0x372
c010a467:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a46c:	e8 15 69 ff ff       	call   c0100d86 <__panic>
    }

    initproc = find_proc(pid);
c010a471:	83 ec 0c             	sub    $0xc,%esp
c010a474:	ff 75 f0             	pushl  -0x10(%ebp)
c010a477:	e8 f7 ec ff ff       	call   c0109173 <find_proc>
c010a47c:	83 c4 10             	add    $0x10,%esp
c010a47f:	a3 2c 41 1a c0       	mov    %eax,0xc01a412c
    set_proc_name(initproc, "init");
c010a484:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a489:	83 ec 08             	sub    $0x8,%esp
c010a48c:	68 c0 d9 10 c0       	push   $0xc010d9c0
c010a491:	50                   	push   %eax
c010a492:	e8 fb e8 ff ff       	call   c0108d92 <set_proc_name>
c010a497:	83 c4 10             	add    $0x10,%esp

    assert(idleproc != NULL && idleproc->pid == 0);
c010a49a:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a49f:	85 c0                	test   %eax,%eax
c010a4a1:	74 0c                	je     c010a4af <proc_init+0x154>
c010a4a3:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a4a8:	8b 40 04             	mov    0x4(%eax),%eax
c010a4ab:	85 c0                	test   %eax,%eax
c010a4ad:	74 19                	je     c010a4c8 <proc_init+0x16d>
c010a4af:	68 c8 d9 10 c0       	push   $0xc010d9c8
c010a4b4:	68 03 d6 10 c0       	push   $0xc010d603
c010a4b9:	68 78 03 00 00       	push   $0x378
c010a4be:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a4c3:	e8 be 68 ff ff       	call   c0100d86 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010a4c8:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a4cd:	85 c0                	test   %eax,%eax
c010a4cf:	74 0d                	je     c010a4de <proc_init+0x183>
c010a4d1:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a4d6:	8b 40 04             	mov    0x4(%eax),%eax
c010a4d9:	83 f8 01             	cmp    $0x1,%eax
c010a4dc:	74 19                	je     c010a4f7 <proc_init+0x19c>
c010a4de:	68 f0 d9 10 c0       	push   $0xc010d9f0
c010a4e3:	68 03 d6 10 c0       	push   $0xc010d603
c010a4e8:	68 79 03 00 00       	push   $0x379
c010a4ed:	68 c1 d5 10 c0       	push   $0xc010d5c1
c010a4f2:	e8 8f 68 ff ff       	call   c0100d86 <__panic>
}
c010a4f7:	90                   	nop
c010a4f8:	c9                   	leave  
c010a4f9:	c3                   	ret    

c010a4fa <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010a4fa:	55                   	push   %ebp
c010a4fb:	89 e5                	mov    %esp,%ebp
c010a4fd:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010a500:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a505:	8b 40 10             	mov    0x10(%eax),%eax
c010a508:	85 c0                	test   %eax,%eax
c010a50a:	74 f4                	je     c010a500 <cpu_idle+0x6>
            schedule();
c010a50c:	e8 ec 00 00 00       	call   c010a5fd <schedule>
        if (current->need_resched) {
c010a511:	eb ed                	jmp    c010a500 <cpu_idle+0x6>

c010a513 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010a513:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010a517:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010a519:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010a51c:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010a51f:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010a522:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010a525:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010a528:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010a52b:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010a52e:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010a532:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010a535:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010a538:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010a53b:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010a53e:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010a541:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010a544:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010a547:	ff 30                	pushl  (%eax)

    ret
c010a549:	c3                   	ret    

c010a54a <__intr_save>:
__intr_save(void) {
c010a54a:	55                   	push   %ebp
c010a54b:	89 e5                	mov    %esp,%ebp
c010a54d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010a550:	9c                   	pushf  
c010a551:	58                   	pop    %eax
c010a552:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010a555:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010a558:	25 00 02 00 00       	and    $0x200,%eax
c010a55d:	85 c0                	test   %eax,%eax
c010a55f:	74 0c                	je     c010a56d <__intr_save+0x23>
        intr_disable();
c010a561:	e8 25 7a ff ff       	call   c0101f8b <intr_disable>
        return 1;
c010a566:	b8 01 00 00 00       	mov    $0x1,%eax
c010a56b:	eb 05                	jmp    c010a572 <__intr_save+0x28>
    return 0;
c010a56d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a572:	c9                   	leave  
c010a573:	c3                   	ret    

c010a574 <__intr_restore>:
__intr_restore(bool flag) {
c010a574:	55                   	push   %ebp
c010a575:	89 e5                	mov    %esp,%ebp
c010a577:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010a57a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a57e:	74 05                	je     c010a585 <__intr_restore+0x11>
        intr_enable();
c010a580:	e8 fe 79 ff ff       	call   c0101f83 <intr_enable>
}
c010a585:	90                   	nop
c010a586:	c9                   	leave  
c010a587:	c3                   	ret    

c010a588 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010a588:	55                   	push   %ebp
c010a589:	89 e5                	mov    %esp,%ebp
c010a58b:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE);
c010a58e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a591:	8b 00                	mov    (%eax),%eax
c010a593:	83 f8 03             	cmp    $0x3,%eax
c010a596:	75 16                	jne    c010a5ae <wakeup_proc+0x26>
c010a598:	68 17 da 10 c0       	push   $0xc010da17
c010a59d:	68 32 da 10 c0       	push   $0xc010da32
c010a5a2:	6a 09                	push   $0x9
c010a5a4:	68 47 da 10 c0       	push   $0xc010da47
c010a5a9:	e8 d8 67 ff ff       	call   c0100d86 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010a5ae:	e8 97 ff ff ff       	call   c010a54a <__intr_save>
c010a5b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010a5b6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5b9:	8b 00                	mov    (%eax),%eax
c010a5bb:	83 f8 02             	cmp    $0x2,%eax
c010a5be:	74 15                	je     c010a5d5 <wakeup_proc+0x4d>
            proc->state = PROC_RUNNABLE;
c010a5c0:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5c3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010a5c9:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5cc:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010a5d3:	eb 17                	jmp    c010a5ec <wakeup_proc+0x64>
        }
        else {
            warn("wakeup runnable process.\n");
c010a5d5:	83 ec 04             	sub    $0x4,%esp
c010a5d8:	68 5d da 10 c0       	push   $0xc010da5d
c010a5dd:	6a 12                	push   $0x12
c010a5df:	68 47 da 10 c0       	push   $0xc010da47
c010a5e4:	e8 20 68 ff ff       	call   c0100e09 <__warn>
c010a5e9:	83 c4 10             	add    $0x10,%esp
        }
    }
    local_intr_restore(intr_flag);
c010a5ec:	83 ec 0c             	sub    $0xc,%esp
c010a5ef:	ff 75 f4             	pushl  -0xc(%ebp)
c010a5f2:	e8 7d ff ff ff       	call   c010a574 <__intr_restore>
c010a5f7:	83 c4 10             	add    $0x10,%esp
}
c010a5fa:	90                   	nop
c010a5fb:	c9                   	leave  
c010a5fc:	c3                   	ret    

c010a5fd <schedule>:

void
schedule(void) {
c010a5fd:	55                   	push   %ebp
c010a5fe:	89 e5                	mov    %esp,%ebp
c010a600:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010a603:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);	//inhibit interrupt
c010a60a:	e8 3b ff ff ff       	call   c010a54a <__intr_save>
c010a60f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010a612:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a617:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010a61e:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c010a624:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a629:	39 c2                	cmp    %eax,%edx
c010a62b:	74 0a                	je     c010a637 <schedule+0x3a>
c010a62d:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a632:	83 c0 58             	add    $0x58,%eax
c010a635:	eb 05                	jmp    c010a63c <schedule+0x3f>
c010a637:	b8 20 41 1a c0       	mov    $0xc01a4120,%eax
c010a63c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010a63f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a642:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a645:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a648:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010a64b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a64e:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010a651:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a654:	81 7d f4 20 41 1a c0 	cmpl   $0xc01a4120,-0xc(%ebp)
c010a65b:	74 13                	je     c010a670 <schedule+0x73>
                next = le2proc(le, list_link);
c010a65d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a660:	83 e8 58             	sub    $0x58,%eax
c010a663:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010a666:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a669:	8b 00                	mov    (%eax),%eax
c010a66b:	83 f8 02             	cmp    $0x2,%eax
c010a66e:	74 0a                	je     c010a67a <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c010a670:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a673:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010a676:	75 cd                	jne    c010a645 <schedule+0x48>
c010a678:	eb 01                	jmp    c010a67b <schedule+0x7e>
                    break;
c010a67a:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010a67b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a67f:	74 0a                	je     c010a68b <schedule+0x8e>
c010a681:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a684:	8b 00                	mov    (%eax),%eax
c010a686:	83 f8 02             	cmp    $0x2,%eax
c010a689:	74 08                	je     c010a693 <schedule+0x96>
            next = idleproc;
c010a68b:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a690:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010a693:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a696:	8b 40 08             	mov    0x8(%eax),%eax
c010a699:	8d 50 01             	lea    0x1(%eax),%edx
c010a69c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a69f:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010a6a2:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a6a7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010a6aa:	74 0e                	je     c010a6ba <schedule+0xbd>
            proc_run(next);
c010a6ac:	83 ec 0c             	sub    $0xc,%esp
c010a6af:	ff 75 f0             	pushl  -0x10(%ebp)
c010a6b2:	e8 6d e9 ff ff       	call   c0109024 <proc_run>
c010a6b7:	83 c4 10             	add    $0x10,%esp
        }
    }
    local_intr_restore(intr_flag);
c010a6ba:	83 ec 0c             	sub    $0xc,%esp
c010a6bd:	ff 75 ec             	pushl  -0x14(%ebp)
c010a6c0:	e8 af fe ff ff       	call   c010a574 <__intr_restore>
c010a6c5:	83 c4 10             	add    $0x10,%esp
}
c010a6c8:	90                   	nop
c010a6c9:	c9                   	leave  
c010a6ca:	c3                   	ret    

c010a6cb <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010a6cb:	55                   	push   %ebp
c010a6cc:	89 e5                	mov    %esp,%ebp
c010a6ce:	83 ec 18             	sub    $0x18,%esp
    int error_code = (int)arg[0];
c010a6d1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6d4:	8b 00                	mov    (%eax),%eax
c010a6d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010a6d9:	83 ec 0c             	sub    $0xc,%esp
c010a6dc:	ff 75 f4             	pushl  -0xc(%ebp)
c010a6df:	e8 ae ef ff ff       	call   c0109692 <do_exit>
c010a6e4:	83 c4 10             	add    $0x10,%esp
}
c010a6e7:	c9                   	leave  
c010a6e8:	c3                   	ret    

c010a6e9 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010a6e9:	55                   	push   %ebp
c010a6ea:	89 e5                	mov    %esp,%ebp
c010a6ec:	83 ec 18             	sub    $0x18,%esp
    struct trapframe *tf = current->tf;
c010a6ef:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a6f4:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a6f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010a6fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a6fd:	8b 40 44             	mov    0x44(%eax),%eax
c010a700:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010a703:	83 ec 04             	sub    $0x4,%esp
c010a706:	ff 75 f4             	pushl  -0xc(%ebp)
c010a709:	ff 75 f0             	pushl  -0x10(%ebp)
c010a70c:	6a 00                	push   $0x0
c010a70e:	e8 23 ee ff ff       	call   c0109536 <do_fork>
c010a713:	83 c4 10             	add    $0x10,%esp
}
c010a716:	c9                   	leave  
c010a717:	c3                   	ret    

c010a718 <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010a718:	55                   	push   %ebp
c010a719:	89 e5                	mov    %esp,%ebp
c010a71b:	83 ec 18             	sub    $0x18,%esp
    int pid = (int)arg[0];
c010a71e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a721:	8b 00                	mov    (%eax),%eax
c010a723:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010a726:	8b 45 08             	mov    0x8(%ebp),%eax
c010a729:	83 c0 04             	add    $0x4,%eax
c010a72c:	8b 00                	mov    (%eax),%eax
c010a72e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010a731:	83 ec 08             	sub    $0x8,%esp
c010a734:	ff 75 f0             	pushl  -0x10(%ebp)
c010a737:	ff 75 f4             	pushl  -0xc(%ebp)
c010a73a:	e8 44 f8 ff ff       	call   c0109f83 <do_wait>
c010a73f:	83 c4 10             	add    $0x10,%esp
}
c010a742:	c9                   	leave  
c010a743:	c3                   	ret    

c010a744 <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010a744:	55                   	push   %ebp
c010a745:	89 e5                	mov    %esp,%ebp
c010a747:	83 ec 18             	sub    $0x18,%esp
    const char *name = (const char *)arg[0];
c010a74a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a74d:	8b 00                	mov    (%eax),%eax
c010a74f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010a752:	8b 45 08             	mov    0x8(%ebp),%eax
c010a755:	83 c0 04             	add    $0x4,%eax
c010a758:	8b 00                	mov    (%eax),%eax
c010a75a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010a75d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a760:	83 c0 08             	add    $0x8,%eax
c010a763:	8b 00                	mov    (%eax),%eax
c010a765:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010a768:	8b 45 08             	mov    0x8(%ebp),%eax
c010a76b:	83 c0 0c             	add    $0xc,%eax
c010a76e:	8b 00                	mov    (%eax),%eax
c010a770:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010a773:	ff 75 e8             	pushl  -0x18(%ebp)
c010a776:	ff 75 ec             	pushl  -0x14(%ebp)
c010a779:	ff 75 f0             	pushl  -0x10(%ebp)
c010a77c:	ff 75 f4             	pushl  -0xc(%ebp)
c010a77f:	e8 c6 f6 ff ff       	call   c0109e4a <do_execve>
c010a784:	83 c4 10             	add    $0x10,%esp
}
c010a787:	c9                   	leave  
c010a788:	c3                   	ret    

c010a789 <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010a789:	55                   	push   %ebp
c010a78a:	89 e5                	mov    %esp,%ebp
c010a78c:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010a78f:	e8 d9 f7 ff ff       	call   c0109f6d <do_yield>
}
c010a794:	c9                   	leave  
c010a795:	c3                   	ret    

c010a796 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010a796:	55                   	push   %ebp
c010a797:	89 e5                	mov    %esp,%ebp
c010a799:	83 ec 18             	sub    $0x18,%esp
    int pid = (int)arg[0];
c010a79c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a79f:	8b 00                	mov    (%eax),%eax
c010a7a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010a7a4:	83 ec 0c             	sub    $0xc,%esp
c010a7a7:	ff 75 f4             	pushl  -0xc(%ebp)
c010a7aa:	e8 63 f9 ff ff       	call   c010a112 <do_kill>
c010a7af:	83 c4 10             	add    $0x10,%esp
}
c010a7b2:	c9                   	leave  
c010a7b3:	c3                   	ret    

c010a7b4 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010a7b4:	55                   	push   %ebp
c010a7b5:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010a7b7:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a7bc:	8b 40 04             	mov    0x4(%eax),%eax
}
c010a7bf:	5d                   	pop    %ebp
c010a7c0:	c3                   	ret    

c010a7c1 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010a7c1:	55                   	push   %ebp
c010a7c2:	89 e5                	mov    %esp,%ebp
c010a7c4:	83 ec 18             	sub    $0x18,%esp
    int c = (int)arg[0];
c010a7c7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7ca:	8b 00                	mov    (%eax),%eax
c010a7cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010a7cf:	83 ec 0c             	sub    $0xc,%esp
c010a7d2:	ff 75 f4             	pushl  -0xc(%ebp)
c010a7d5:	e8 94 5b ff ff       	call   c010036e <cputchar>
c010a7da:	83 c4 10             	add    $0x10,%esp
    return 0;
c010a7dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a7e2:	c9                   	leave  
c010a7e3:	c3                   	ret    

c010a7e4 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010a7e4:	55                   	push   %ebp
c010a7e5:	89 e5                	mov    %esp,%ebp
c010a7e7:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010a7ea:	e8 fb be ff ff       	call   c01066ea <print_pgdir>
    return 0;
c010a7ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a7f4:	c9                   	leave  
c010a7f5:	c3                   	ret    

c010a7f6 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010a7f6:	55                   	push   %ebp
c010a7f7:	89 e5                	mov    %esp,%ebp
c010a7f9:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010a7fc:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a801:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a804:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010a807:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a80a:	8b 40 1c             	mov    0x1c(%eax),%eax
c010a80d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010a810:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a814:	78 62                	js     c010a878 <syscall+0x82>
c010a816:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a819:	83 f8 1f             	cmp    $0x1f,%eax
c010a81c:	77 5a                	ja     c010a878 <syscall+0x82>
        if (syscalls[num] != NULL) {
c010a81e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a821:	8b 04 85 a0 fa 12 c0 	mov    -0x3fed0560(,%eax,4),%eax
c010a828:	85 c0                	test   %eax,%eax
c010a82a:	74 4c                	je     c010a878 <syscall+0x82>
            arg[0] = tf->tf_regs.reg_edx;
c010a82c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a82f:	8b 40 14             	mov    0x14(%eax),%eax
c010a832:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010a835:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a838:	8b 40 18             	mov    0x18(%eax),%eax
c010a83b:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010a83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a841:	8b 40 10             	mov    0x10(%eax),%eax
c010a844:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010a847:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a84a:	8b 00                	mov    (%eax),%eax
c010a84c:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010a84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a852:	8b 40 04             	mov    0x4(%eax),%eax
c010a855:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);	//`syscalls[num]` is function ptr, and `(arg)` is argument
c010a858:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a85b:	8b 04 85 a0 fa 12 c0 	mov    -0x3fed0560(,%eax,4),%eax
c010a862:	83 ec 0c             	sub    $0xc,%esp
c010a865:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a868:	52                   	push   %edx
c010a869:	ff d0                	call   *%eax
c010a86b:	83 c4 10             	add    $0x10,%esp
c010a86e:	89 c2                	mov    %eax,%edx
c010a870:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a873:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010a876:	eb 37                	jmp    c010a8af <syscall+0xb9>
        }
    }
    print_trapframe(tf);
c010a878:	83 ec 0c             	sub    $0xc,%esp
c010a87b:	ff 75 f4             	pushl  -0xc(%ebp)
c010a87e:	e8 37 7b ff ff       	call   c01023ba <print_trapframe>
c010a883:	83 c4 10             	add    $0x10,%esp
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010a886:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a88b:	8d 50 48             	lea    0x48(%eax),%edx
c010a88e:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a893:	8b 40 04             	mov    0x4(%eax),%eax
c010a896:	83 ec 08             	sub    $0x8,%esp
c010a899:	52                   	push   %edx
c010a89a:	50                   	push   %eax
c010a89b:	ff 75 f0             	pushl  -0x10(%ebp)
c010a89e:	68 78 da 10 c0       	push   $0xc010da78
c010a8a3:	6a 62                	push   $0x62
c010a8a5:	68 a4 da 10 c0       	push   $0xc010daa4
c010a8aa:	e8 d7 64 ff ff       	call   c0100d86 <__panic>
            num, current->pid, current->name);
}
c010a8af:	c9                   	leave  
c010a8b0:	c3                   	ret    

c010a8b1 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010a8b1:	55                   	push   %ebp
c010a8b2:	89 e5                	mov    %esp,%ebp
c010a8b4:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010a8b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8ba:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010a8c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010a8c3:	b8 20 00 00 00       	mov    $0x20,%eax
c010a8c8:	2b 45 0c             	sub    0xc(%ebp),%eax
c010a8cb:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a8ce:	89 c1                	mov    %eax,%ecx
c010a8d0:	d3 ea                	shr    %cl,%edx
c010a8d2:	89 d0                	mov    %edx,%eax
}
c010a8d4:	c9                   	leave  
c010a8d5:	c3                   	ret    

c010a8d6 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010a8d6:	55                   	push   %ebp
c010a8d7:	89 e5                	mov    %esp,%ebp
c010a8d9:	83 ec 38             	sub    $0x38,%esp
c010a8dc:	8b 45 10             	mov    0x10(%ebp),%eax
c010a8df:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a8e2:	8b 45 14             	mov    0x14(%ebp),%eax
c010a8e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010a8e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a8ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a8f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010a8f4:	8b 45 18             	mov    0x18(%ebp),%eax
c010a8f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a8fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a8fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a900:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a903:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010a906:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a909:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a90c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a910:	74 1c                	je     c010a92e <printnum+0x58>
c010a912:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a915:	ba 00 00 00 00       	mov    $0x0,%edx
c010a91a:	f7 75 e4             	divl   -0x1c(%ebp)
c010a91d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010a920:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a923:	ba 00 00 00 00       	mov    $0x0,%edx
c010a928:	f7 75 e4             	divl   -0x1c(%ebp)
c010a92b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a92e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a931:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a934:	f7 75 e4             	divl   -0x1c(%ebp)
c010a937:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a93a:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010a93d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a940:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a943:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a946:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a949:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a94c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010a94f:	8b 45 18             	mov    0x18(%ebp),%eax
c010a952:	ba 00 00 00 00       	mov    $0x0,%edx
c010a957:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010a95a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010a95d:	19 d1                	sbb    %edx,%ecx
c010a95f:	72 37                	jb     c010a998 <printnum+0xc2>
        printnum(putch, putdat, result, base, width - 1, padc);
c010a961:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010a964:	83 e8 01             	sub    $0x1,%eax
c010a967:	83 ec 04             	sub    $0x4,%esp
c010a96a:	ff 75 20             	pushl  0x20(%ebp)
c010a96d:	50                   	push   %eax
c010a96e:	ff 75 18             	pushl  0x18(%ebp)
c010a971:	ff 75 ec             	pushl  -0x14(%ebp)
c010a974:	ff 75 e8             	pushl  -0x18(%ebp)
c010a977:	ff 75 0c             	pushl  0xc(%ebp)
c010a97a:	ff 75 08             	pushl  0x8(%ebp)
c010a97d:	e8 54 ff ff ff       	call   c010a8d6 <printnum>
c010a982:	83 c4 20             	add    $0x20,%esp
c010a985:	eb 1b                	jmp    c010a9a2 <printnum+0xcc>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010a987:	83 ec 08             	sub    $0x8,%esp
c010a98a:	ff 75 0c             	pushl  0xc(%ebp)
c010a98d:	ff 75 20             	pushl  0x20(%ebp)
c010a990:	8b 45 08             	mov    0x8(%ebp),%eax
c010a993:	ff d0                	call   *%eax
c010a995:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
c010a998:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010a99c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010a9a0:	7f e5                	jg     c010a987 <printnum+0xb1>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010a9a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a9a5:	05 c4 db 10 c0       	add    $0xc010dbc4,%eax
c010a9aa:	0f b6 00             	movzbl (%eax),%eax
c010a9ad:	0f be c0             	movsbl %al,%eax
c010a9b0:	83 ec 08             	sub    $0x8,%esp
c010a9b3:	ff 75 0c             	pushl  0xc(%ebp)
c010a9b6:	50                   	push   %eax
c010a9b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9ba:	ff d0                	call   *%eax
c010a9bc:	83 c4 10             	add    $0x10,%esp
}
c010a9bf:	90                   	nop
c010a9c0:	c9                   	leave  
c010a9c1:	c3                   	ret    

c010a9c2 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010a9c2:	55                   	push   %ebp
c010a9c3:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a9c5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a9c9:	7e 14                	jle    c010a9df <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010a9cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9ce:	8b 00                	mov    (%eax),%eax
c010a9d0:	8d 48 08             	lea    0x8(%eax),%ecx
c010a9d3:	8b 55 08             	mov    0x8(%ebp),%edx
c010a9d6:	89 0a                	mov    %ecx,(%edx)
c010a9d8:	8b 50 04             	mov    0x4(%eax),%edx
c010a9db:	8b 00                	mov    (%eax),%eax
c010a9dd:	eb 30                	jmp    c010aa0f <getuint+0x4d>
    }
    else if (lflag) {
c010a9df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a9e3:	74 16                	je     c010a9fb <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010a9e5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9e8:	8b 00                	mov    (%eax),%eax
c010a9ea:	8d 48 04             	lea    0x4(%eax),%ecx
c010a9ed:	8b 55 08             	mov    0x8(%ebp),%edx
c010a9f0:	89 0a                	mov    %ecx,(%edx)
c010a9f2:	8b 00                	mov    (%eax),%eax
c010a9f4:	ba 00 00 00 00       	mov    $0x0,%edx
c010a9f9:	eb 14                	jmp    c010aa0f <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010a9fb:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9fe:	8b 00                	mov    (%eax),%eax
c010aa00:	8d 48 04             	lea    0x4(%eax),%ecx
c010aa03:	8b 55 08             	mov    0x8(%ebp),%edx
c010aa06:	89 0a                	mov    %ecx,(%edx)
c010aa08:	8b 00                	mov    (%eax),%eax
c010aa0a:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010aa0f:	5d                   	pop    %ebp
c010aa10:	c3                   	ret    

c010aa11 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010aa11:	55                   	push   %ebp
c010aa12:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010aa14:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010aa18:	7e 14                	jle    c010aa2e <getint+0x1d>
        return va_arg(*ap, long long);
c010aa1a:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa1d:	8b 00                	mov    (%eax),%eax
c010aa1f:	8d 48 08             	lea    0x8(%eax),%ecx
c010aa22:	8b 55 08             	mov    0x8(%ebp),%edx
c010aa25:	89 0a                	mov    %ecx,(%edx)
c010aa27:	8b 50 04             	mov    0x4(%eax),%edx
c010aa2a:	8b 00                	mov    (%eax),%eax
c010aa2c:	eb 28                	jmp    c010aa56 <getint+0x45>
    }
    else if (lflag) {
c010aa2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010aa32:	74 12                	je     c010aa46 <getint+0x35>
        return va_arg(*ap, long);
c010aa34:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa37:	8b 00                	mov    (%eax),%eax
c010aa39:	8d 48 04             	lea    0x4(%eax),%ecx
c010aa3c:	8b 55 08             	mov    0x8(%ebp),%edx
c010aa3f:	89 0a                	mov    %ecx,(%edx)
c010aa41:	8b 00                	mov    (%eax),%eax
c010aa43:	99                   	cltd   
c010aa44:	eb 10                	jmp    c010aa56 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010aa46:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa49:	8b 00                	mov    (%eax),%eax
c010aa4b:	8d 48 04             	lea    0x4(%eax),%ecx
c010aa4e:	8b 55 08             	mov    0x8(%ebp),%edx
c010aa51:	89 0a                	mov    %ecx,(%edx)
c010aa53:	8b 00                	mov    (%eax),%eax
c010aa55:	99                   	cltd   
    }
}
c010aa56:	5d                   	pop    %ebp
c010aa57:	c3                   	ret    

c010aa58 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010aa58:	55                   	push   %ebp
c010aa59:	89 e5                	mov    %esp,%ebp
c010aa5b:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c010aa5e:	8d 45 14             	lea    0x14(%ebp),%eax
c010aa61:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010aa64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa67:	50                   	push   %eax
c010aa68:	ff 75 10             	pushl  0x10(%ebp)
c010aa6b:	ff 75 0c             	pushl  0xc(%ebp)
c010aa6e:	ff 75 08             	pushl  0x8(%ebp)
c010aa71:	e8 06 00 00 00       	call   c010aa7c <vprintfmt>
c010aa76:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010aa79:	90                   	nop
c010aa7a:	c9                   	leave  
c010aa7b:	c3                   	ret    

c010aa7c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010aa7c:	55                   	push   %ebp
c010aa7d:	89 e5                	mov    %esp,%ebp
c010aa7f:	56                   	push   %esi
c010aa80:	53                   	push   %ebx
c010aa81:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010aa84:	eb 17                	jmp    c010aa9d <vprintfmt+0x21>
            if (ch == '\0') {
c010aa86:	85 db                	test   %ebx,%ebx
c010aa88:	0f 84 8e 03 00 00    	je     c010ae1c <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c010aa8e:	83 ec 08             	sub    $0x8,%esp
c010aa91:	ff 75 0c             	pushl  0xc(%ebp)
c010aa94:	53                   	push   %ebx
c010aa95:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa98:	ff d0                	call   *%eax
c010aa9a:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010aa9d:	8b 45 10             	mov    0x10(%ebp),%eax
c010aaa0:	8d 50 01             	lea    0x1(%eax),%edx
c010aaa3:	89 55 10             	mov    %edx,0x10(%ebp)
c010aaa6:	0f b6 00             	movzbl (%eax),%eax
c010aaa9:	0f b6 d8             	movzbl %al,%ebx
c010aaac:	83 fb 25             	cmp    $0x25,%ebx
c010aaaf:	75 d5                	jne    c010aa86 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010aab1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010aab5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010aabc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010aabf:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010aac2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010aac9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010aacc:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010aacf:	8b 45 10             	mov    0x10(%ebp),%eax
c010aad2:	8d 50 01             	lea    0x1(%eax),%edx
c010aad5:	89 55 10             	mov    %edx,0x10(%ebp)
c010aad8:	0f b6 00             	movzbl (%eax),%eax
c010aadb:	0f b6 d8             	movzbl %al,%ebx
c010aade:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010aae1:	83 f8 55             	cmp    $0x55,%eax
c010aae4:	0f 87 05 03 00 00    	ja     c010adef <vprintfmt+0x373>
c010aaea:	8b 04 85 e8 db 10 c0 	mov    -0x3fef2418(,%eax,4),%eax
c010aaf1:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010aaf3:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010aaf7:	eb d6                	jmp    c010aacf <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010aaf9:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010aafd:	eb d0                	jmp    c010aacf <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010aaff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010ab06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010ab09:	89 d0                	mov    %edx,%eax
c010ab0b:	c1 e0 02             	shl    $0x2,%eax
c010ab0e:	01 d0                	add    %edx,%eax
c010ab10:	01 c0                	add    %eax,%eax
c010ab12:	01 d8                	add    %ebx,%eax
c010ab14:	83 e8 30             	sub    $0x30,%eax
c010ab17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010ab1a:	8b 45 10             	mov    0x10(%ebp),%eax
c010ab1d:	0f b6 00             	movzbl (%eax),%eax
c010ab20:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010ab23:	83 fb 2f             	cmp    $0x2f,%ebx
c010ab26:	7e 39                	jle    c010ab61 <vprintfmt+0xe5>
c010ab28:	83 fb 39             	cmp    $0x39,%ebx
c010ab2b:	7f 34                	jg     c010ab61 <vprintfmt+0xe5>
            for (precision = 0; ; ++ fmt) {
c010ab2d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010ab31:	eb d3                	jmp    c010ab06 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010ab33:	8b 45 14             	mov    0x14(%ebp),%eax
c010ab36:	8d 50 04             	lea    0x4(%eax),%edx
c010ab39:	89 55 14             	mov    %edx,0x14(%ebp)
c010ab3c:	8b 00                	mov    (%eax),%eax
c010ab3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010ab41:	eb 1f                	jmp    c010ab62 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c010ab43:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ab47:	79 86                	jns    c010aacf <vprintfmt+0x53>
                width = 0;
c010ab49:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010ab50:	e9 7a ff ff ff       	jmp    c010aacf <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010ab55:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010ab5c:	e9 6e ff ff ff       	jmp    c010aacf <vprintfmt+0x53>
            goto process_precision;
c010ab61:	90                   	nop

        process_precision:
            if (width < 0)
c010ab62:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ab66:	0f 89 63 ff ff ff    	jns    c010aacf <vprintfmt+0x53>
                width = precision, precision = -1;
c010ab6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ab6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ab72:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010ab79:	e9 51 ff ff ff       	jmp    c010aacf <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010ab7e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010ab82:	e9 48 ff ff ff       	jmp    c010aacf <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010ab87:	8b 45 14             	mov    0x14(%ebp),%eax
c010ab8a:	8d 50 04             	lea    0x4(%eax),%edx
c010ab8d:	89 55 14             	mov    %edx,0x14(%ebp)
c010ab90:	8b 00                	mov    (%eax),%eax
c010ab92:	83 ec 08             	sub    $0x8,%esp
c010ab95:	ff 75 0c             	pushl  0xc(%ebp)
c010ab98:	50                   	push   %eax
c010ab99:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab9c:	ff d0                	call   *%eax
c010ab9e:	83 c4 10             	add    $0x10,%esp
            break;
c010aba1:	e9 71 02 00 00       	jmp    c010ae17 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010aba6:	8b 45 14             	mov    0x14(%ebp),%eax
c010aba9:	8d 50 04             	lea    0x4(%eax),%edx
c010abac:	89 55 14             	mov    %edx,0x14(%ebp)
c010abaf:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010abb1:	85 db                	test   %ebx,%ebx
c010abb3:	79 02                	jns    c010abb7 <vprintfmt+0x13b>
                err = -err;
c010abb5:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010abb7:	83 fb 18             	cmp    $0x18,%ebx
c010abba:	7f 0b                	jg     c010abc7 <vprintfmt+0x14b>
c010abbc:	8b 34 9d 60 db 10 c0 	mov    -0x3fef24a0(,%ebx,4),%esi
c010abc3:	85 f6                	test   %esi,%esi
c010abc5:	75 19                	jne    c010abe0 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c010abc7:	53                   	push   %ebx
c010abc8:	68 d5 db 10 c0       	push   $0xc010dbd5
c010abcd:	ff 75 0c             	pushl  0xc(%ebp)
c010abd0:	ff 75 08             	pushl  0x8(%ebp)
c010abd3:	e8 80 fe ff ff       	call   c010aa58 <printfmt>
c010abd8:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010abdb:	e9 37 02 00 00       	jmp    c010ae17 <vprintfmt+0x39b>
                printfmt(putch, putdat, "%s", p);
c010abe0:	56                   	push   %esi
c010abe1:	68 de db 10 c0       	push   $0xc010dbde
c010abe6:	ff 75 0c             	pushl  0xc(%ebp)
c010abe9:	ff 75 08             	pushl  0x8(%ebp)
c010abec:	e8 67 fe ff ff       	call   c010aa58 <printfmt>
c010abf1:	83 c4 10             	add    $0x10,%esp
            break;
c010abf4:	e9 1e 02 00 00       	jmp    c010ae17 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010abf9:	8b 45 14             	mov    0x14(%ebp),%eax
c010abfc:	8d 50 04             	lea    0x4(%eax),%edx
c010abff:	89 55 14             	mov    %edx,0x14(%ebp)
c010ac02:	8b 30                	mov    (%eax),%esi
c010ac04:	85 f6                	test   %esi,%esi
c010ac06:	75 05                	jne    c010ac0d <vprintfmt+0x191>
                p = "(null)";
c010ac08:	be e1 db 10 c0       	mov    $0xc010dbe1,%esi
            }
            if (width > 0 && padc != '-') {
c010ac0d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ac11:	7e 76                	jle    c010ac89 <vprintfmt+0x20d>
c010ac13:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010ac17:	74 70                	je     c010ac89 <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010ac19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ac1c:	83 ec 08             	sub    $0x8,%esp
c010ac1f:	50                   	push   %eax
c010ac20:	56                   	push   %esi
c010ac21:	e8 b7 03 00 00       	call   c010afdd <strnlen>
c010ac26:	83 c4 10             	add    $0x10,%esp
c010ac29:	89 c2                	mov    %eax,%edx
c010ac2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ac2e:	29 d0                	sub    %edx,%eax
c010ac30:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ac33:	eb 17                	jmp    c010ac4c <vprintfmt+0x1d0>
                    putch(padc, putdat);
c010ac35:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010ac39:	83 ec 08             	sub    $0x8,%esp
c010ac3c:	ff 75 0c             	pushl  0xc(%ebp)
c010ac3f:	50                   	push   %eax
c010ac40:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac43:	ff d0                	call   *%eax
c010ac45:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
c010ac48:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010ac4c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ac50:	7f e3                	jg     c010ac35 <vprintfmt+0x1b9>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010ac52:	eb 35                	jmp    c010ac89 <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c010ac54:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010ac58:	74 1c                	je     c010ac76 <vprintfmt+0x1fa>
c010ac5a:	83 fb 1f             	cmp    $0x1f,%ebx
c010ac5d:	7e 05                	jle    c010ac64 <vprintfmt+0x1e8>
c010ac5f:	83 fb 7e             	cmp    $0x7e,%ebx
c010ac62:	7e 12                	jle    c010ac76 <vprintfmt+0x1fa>
                    putch('?', putdat);
c010ac64:	83 ec 08             	sub    $0x8,%esp
c010ac67:	ff 75 0c             	pushl  0xc(%ebp)
c010ac6a:	6a 3f                	push   $0x3f
c010ac6c:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac6f:	ff d0                	call   *%eax
c010ac71:	83 c4 10             	add    $0x10,%esp
c010ac74:	eb 0f                	jmp    c010ac85 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c010ac76:	83 ec 08             	sub    $0x8,%esp
c010ac79:	ff 75 0c             	pushl  0xc(%ebp)
c010ac7c:	53                   	push   %ebx
c010ac7d:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac80:	ff d0                	call   *%eax
c010ac82:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010ac85:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010ac89:	89 f0                	mov    %esi,%eax
c010ac8b:	8d 70 01             	lea    0x1(%eax),%esi
c010ac8e:	0f b6 00             	movzbl (%eax),%eax
c010ac91:	0f be d8             	movsbl %al,%ebx
c010ac94:	85 db                	test   %ebx,%ebx
c010ac96:	74 26                	je     c010acbe <vprintfmt+0x242>
c010ac98:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010ac9c:	78 b6                	js     c010ac54 <vprintfmt+0x1d8>
c010ac9e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010aca2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010aca6:	79 ac                	jns    c010ac54 <vprintfmt+0x1d8>
                }
            }
            for (; width > 0; width --) {
c010aca8:	eb 14                	jmp    c010acbe <vprintfmt+0x242>
                putch(' ', putdat);
c010acaa:	83 ec 08             	sub    $0x8,%esp
c010acad:	ff 75 0c             	pushl  0xc(%ebp)
c010acb0:	6a 20                	push   $0x20
c010acb2:	8b 45 08             	mov    0x8(%ebp),%eax
c010acb5:	ff d0                	call   *%eax
c010acb7:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
c010acba:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010acbe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010acc2:	7f e6                	jg     c010acaa <vprintfmt+0x22e>
            }
            break;
c010acc4:	e9 4e 01 00 00       	jmp    c010ae17 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010acc9:	83 ec 08             	sub    $0x8,%esp
c010accc:	ff 75 e0             	pushl  -0x20(%ebp)
c010accf:	8d 45 14             	lea    0x14(%ebp),%eax
c010acd2:	50                   	push   %eax
c010acd3:	e8 39 fd ff ff       	call   c010aa11 <getint>
c010acd8:	83 c4 10             	add    $0x10,%esp
c010acdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010acde:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010ace1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ace4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010ace7:	85 d2                	test   %edx,%edx
c010ace9:	79 23                	jns    c010ad0e <vprintfmt+0x292>
                putch('-', putdat);
c010aceb:	83 ec 08             	sub    $0x8,%esp
c010acee:	ff 75 0c             	pushl  0xc(%ebp)
c010acf1:	6a 2d                	push   $0x2d
c010acf3:	8b 45 08             	mov    0x8(%ebp),%eax
c010acf6:	ff d0                	call   *%eax
c010acf8:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c010acfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010acfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010ad01:	f7 d8                	neg    %eax
c010ad03:	83 d2 00             	adc    $0x0,%edx
c010ad06:	f7 da                	neg    %edx
c010ad08:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ad0b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010ad0e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010ad15:	e9 9f 00 00 00       	jmp    c010adb9 <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010ad1a:	83 ec 08             	sub    $0x8,%esp
c010ad1d:	ff 75 e0             	pushl  -0x20(%ebp)
c010ad20:	8d 45 14             	lea    0x14(%ebp),%eax
c010ad23:	50                   	push   %eax
c010ad24:	e8 99 fc ff ff       	call   c010a9c2 <getuint>
c010ad29:	83 c4 10             	add    $0x10,%esp
c010ad2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ad2f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010ad32:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010ad39:	eb 7e                	jmp    c010adb9 <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010ad3b:	83 ec 08             	sub    $0x8,%esp
c010ad3e:	ff 75 e0             	pushl  -0x20(%ebp)
c010ad41:	8d 45 14             	lea    0x14(%ebp),%eax
c010ad44:	50                   	push   %eax
c010ad45:	e8 78 fc ff ff       	call   c010a9c2 <getuint>
c010ad4a:	83 c4 10             	add    $0x10,%esp
c010ad4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ad50:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010ad53:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010ad5a:	eb 5d                	jmp    c010adb9 <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c010ad5c:	83 ec 08             	sub    $0x8,%esp
c010ad5f:	ff 75 0c             	pushl  0xc(%ebp)
c010ad62:	6a 30                	push   $0x30
c010ad64:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad67:	ff d0                	call   *%eax
c010ad69:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c010ad6c:	83 ec 08             	sub    $0x8,%esp
c010ad6f:	ff 75 0c             	pushl  0xc(%ebp)
c010ad72:	6a 78                	push   $0x78
c010ad74:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad77:	ff d0                	call   *%eax
c010ad79:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010ad7c:	8b 45 14             	mov    0x14(%ebp),%eax
c010ad7f:	8d 50 04             	lea    0x4(%eax),%edx
c010ad82:	89 55 14             	mov    %edx,0x14(%ebp)
c010ad85:	8b 00                	mov    (%eax),%eax
c010ad87:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ad8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010ad91:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010ad98:	eb 1f                	jmp    c010adb9 <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010ad9a:	83 ec 08             	sub    $0x8,%esp
c010ad9d:	ff 75 e0             	pushl  -0x20(%ebp)
c010ada0:	8d 45 14             	lea    0x14(%ebp),%eax
c010ada3:	50                   	push   %eax
c010ada4:	e8 19 fc ff ff       	call   c010a9c2 <getuint>
c010ada9:	83 c4 10             	add    $0x10,%esp
c010adac:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010adaf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010adb2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010adb9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010adbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010adc0:	83 ec 04             	sub    $0x4,%esp
c010adc3:	52                   	push   %edx
c010adc4:	ff 75 e8             	pushl  -0x18(%ebp)
c010adc7:	50                   	push   %eax
c010adc8:	ff 75 f4             	pushl  -0xc(%ebp)
c010adcb:	ff 75 f0             	pushl  -0x10(%ebp)
c010adce:	ff 75 0c             	pushl  0xc(%ebp)
c010add1:	ff 75 08             	pushl  0x8(%ebp)
c010add4:	e8 fd fa ff ff       	call   c010a8d6 <printnum>
c010add9:	83 c4 20             	add    $0x20,%esp
            break;
c010addc:	eb 39                	jmp    c010ae17 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010adde:	83 ec 08             	sub    $0x8,%esp
c010ade1:	ff 75 0c             	pushl  0xc(%ebp)
c010ade4:	53                   	push   %ebx
c010ade5:	8b 45 08             	mov    0x8(%ebp),%eax
c010ade8:	ff d0                	call   *%eax
c010adea:	83 c4 10             	add    $0x10,%esp
            break;
c010aded:	eb 28                	jmp    c010ae17 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010adef:	83 ec 08             	sub    $0x8,%esp
c010adf2:	ff 75 0c             	pushl  0xc(%ebp)
c010adf5:	6a 25                	push   $0x25
c010adf7:	8b 45 08             	mov    0x8(%ebp),%eax
c010adfa:	ff d0                	call   *%eax
c010adfc:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c010adff:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010ae03:	eb 04                	jmp    c010ae09 <vprintfmt+0x38d>
c010ae05:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010ae09:	8b 45 10             	mov    0x10(%ebp),%eax
c010ae0c:	83 e8 01             	sub    $0x1,%eax
c010ae0f:	0f b6 00             	movzbl (%eax),%eax
c010ae12:	3c 25                	cmp    $0x25,%al
c010ae14:	75 ef                	jne    c010ae05 <vprintfmt+0x389>
                /* do nothing */;
            break;
c010ae16:	90                   	nop
    while (1) {
c010ae17:	e9 68 fc ff ff       	jmp    c010aa84 <vprintfmt+0x8>
                return;
c010ae1c:	90                   	nop
        }
    }
}
c010ae1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010ae20:	5b                   	pop    %ebx
c010ae21:	5e                   	pop    %esi
c010ae22:	5d                   	pop    %ebp
c010ae23:	c3                   	ret    

c010ae24 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010ae24:	55                   	push   %ebp
c010ae25:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010ae27:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae2a:	8b 40 08             	mov    0x8(%eax),%eax
c010ae2d:	8d 50 01             	lea    0x1(%eax),%edx
c010ae30:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae33:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010ae36:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae39:	8b 10                	mov    (%eax),%edx
c010ae3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae3e:	8b 40 04             	mov    0x4(%eax),%eax
c010ae41:	39 c2                	cmp    %eax,%edx
c010ae43:	73 12                	jae    c010ae57 <sprintputch+0x33>
        *b->buf ++ = ch;
c010ae45:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae48:	8b 00                	mov    (%eax),%eax
c010ae4a:	8d 48 01             	lea    0x1(%eax),%ecx
c010ae4d:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ae50:	89 0a                	mov    %ecx,(%edx)
c010ae52:	8b 55 08             	mov    0x8(%ebp),%edx
c010ae55:	88 10                	mov    %dl,(%eax)
    }
}
c010ae57:	90                   	nop
c010ae58:	5d                   	pop    %ebp
c010ae59:	c3                   	ret    

c010ae5a <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010ae5a:	55                   	push   %ebp
c010ae5b:	89 e5                	mov    %esp,%ebp
c010ae5d:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010ae60:	8d 45 14             	lea    0x14(%ebp),%eax
c010ae63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010ae66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ae69:	50                   	push   %eax
c010ae6a:	ff 75 10             	pushl  0x10(%ebp)
c010ae6d:	ff 75 0c             	pushl  0xc(%ebp)
c010ae70:	ff 75 08             	pushl  0x8(%ebp)
c010ae73:	e8 0b 00 00 00       	call   c010ae83 <vsnprintf>
c010ae78:	83 c4 10             	add    $0x10,%esp
c010ae7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010ae7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010ae81:	c9                   	leave  
c010ae82:	c3                   	ret    

c010ae83 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010ae83:	55                   	push   %ebp
c010ae84:	89 e5                	mov    %esp,%ebp
c010ae86:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010ae89:	8b 45 08             	mov    0x8(%ebp),%eax
c010ae8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010ae8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae92:	8d 50 ff             	lea    -0x1(%eax),%edx
c010ae95:	8b 45 08             	mov    0x8(%ebp),%eax
c010ae98:	01 d0                	add    %edx,%eax
c010ae9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ae9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010aea4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aea8:	74 0a                	je     c010aeb4 <vsnprintf+0x31>
c010aeaa:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010aead:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aeb0:	39 c2                	cmp    %eax,%edx
c010aeb2:	76 07                	jbe    c010aebb <vsnprintf+0x38>
        return -E_INVAL;
c010aeb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010aeb9:	eb 20                	jmp    c010aedb <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010aebb:	ff 75 14             	pushl  0x14(%ebp)
c010aebe:	ff 75 10             	pushl  0x10(%ebp)
c010aec1:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010aec4:	50                   	push   %eax
c010aec5:	68 24 ae 10 c0       	push   $0xc010ae24
c010aeca:	e8 ad fb ff ff       	call   c010aa7c <vprintfmt>
c010aecf:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c010aed2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aed5:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010aed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010aedb:	c9                   	leave  
c010aedc:	c3                   	ret    

c010aedd <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010aedd:	55                   	push   %ebp
c010aede:	89 e5                	mov    %esp,%ebp
c010aee0:	57                   	push   %edi
c010aee1:	56                   	push   %esi
c010aee2:	53                   	push   %ebx
c010aee3:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010aee6:	a1 20 fb 12 c0       	mov    0xc012fb20,%eax
c010aeeb:	8b 15 24 fb 12 c0    	mov    0xc012fb24,%edx
c010aef1:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010aef7:	6b f0 05             	imul   $0x5,%eax,%esi
c010aefa:	01 fe                	add    %edi,%esi
c010aefc:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010af01:	f7 e7                	mul    %edi
c010af03:	01 d6                	add    %edx,%esi
c010af05:	89 f2                	mov    %esi,%edx
c010af07:	83 c0 0b             	add    $0xb,%eax
c010af0a:	83 d2 00             	adc    $0x0,%edx
c010af0d:	89 c7                	mov    %eax,%edi
c010af0f:	83 e7 ff             	and    $0xffffffff,%edi
c010af12:	89 f9                	mov    %edi,%ecx
c010af14:	0f b7 da             	movzwl %dx,%ebx
c010af17:	89 0d 20 fb 12 c0    	mov    %ecx,0xc012fb20
c010af1d:	89 1d 24 fb 12 c0    	mov    %ebx,0xc012fb24
    unsigned long long result = (next >> 12);
c010af23:	a1 20 fb 12 c0       	mov    0xc012fb20,%eax
c010af28:	8b 15 24 fb 12 c0    	mov    0xc012fb24,%edx
c010af2e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010af32:	c1 ea 0c             	shr    $0xc,%edx
c010af35:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010af38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010af3b:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010af42:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010af45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010af48:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010af4b:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010af4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010af51:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010af54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010af58:	74 1c                	je     c010af76 <rand+0x99>
c010af5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010af5d:	ba 00 00 00 00       	mov    $0x0,%edx
c010af62:	f7 75 dc             	divl   -0x24(%ebp)
c010af65:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010af68:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010af6b:	ba 00 00 00 00       	mov    $0x0,%edx
c010af70:	f7 75 dc             	divl   -0x24(%ebp)
c010af73:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010af76:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010af79:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010af7c:	f7 75 dc             	divl   -0x24(%ebp)
c010af7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010af82:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010af85:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010af88:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010af8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010af8e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010af91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010af94:	83 c4 24             	add    $0x24,%esp
c010af97:	5b                   	pop    %ebx
c010af98:	5e                   	pop    %esi
c010af99:	5f                   	pop    %edi
c010af9a:	5d                   	pop    %ebp
c010af9b:	c3                   	ret    

c010af9c <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010af9c:	55                   	push   %ebp
c010af9d:	89 e5                	mov    %esp,%ebp
    next = seed;
c010af9f:	8b 45 08             	mov    0x8(%ebp),%eax
c010afa2:	ba 00 00 00 00       	mov    $0x0,%edx
c010afa7:	a3 20 fb 12 c0       	mov    %eax,0xc012fb20
c010afac:	89 15 24 fb 12 c0    	mov    %edx,0xc012fb24
}
c010afb2:	90                   	nop
c010afb3:	5d                   	pop    %ebp
c010afb4:	c3                   	ret    

c010afb5 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010afb5:	55                   	push   %ebp
c010afb6:	89 e5                	mov    %esp,%ebp
c010afb8:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010afbb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010afc2:	eb 04                	jmp    c010afc8 <strlen+0x13>
        cnt ++;
c010afc4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c010afc8:	8b 45 08             	mov    0x8(%ebp),%eax
c010afcb:	8d 50 01             	lea    0x1(%eax),%edx
c010afce:	89 55 08             	mov    %edx,0x8(%ebp)
c010afd1:	0f b6 00             	movzbl (%eax),%eax
c010afd4:	84 c0                	test   %al,%al
c010afd6:	75 ec                	jne    c010afc4 <strlen+0xf>
    }
    return cnt;
c010afd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010afdb:	c9                   	leave  
c010afdc:	c3                   	ret    

c010afdd <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010afdd:	55                   	push   %ebp
c010afde:	89 e5                	mov    %esp,%ebp
c010afe0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010afe3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010afea:	eb 04                	jmp    c010aff0 <strnlen+0x13>
        cnt ++;
c010afec:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010aff0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010aff3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010aff6:	73 10                	jae    c010b008 <strnlen+0x2b>
c010aff8:	8b 45 08             	mov    0x8(%ebp),%eax
c010affb:	8d 50 01             	lea    0x1(%eax),%edx
c010affe:	89 55 08             	mov    %edx,0x8(%ebp)
c010b001:	0f b6 00             	movzbl (%eax),%eax
c010b004:	84 c0                	test   %al,%al
c010b006:	75 e4                	jne    c010afec <strnlen+0xf>
    }
    return cnt;
c010b008:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b00b:	c9                   	leave  
c010b00c:	c3                   	ret    

c010b00d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010b00d:	55                   	push   %ebp
c010b00e:	89 e5                	mov    %esp,%ebp
c010b010:	57                   	push   %edi
c010b011:	56                   	push   %esi
c010b012:	83 ec 20             	sub    $0x20,%esp
c010b015:	8b 45 08             	mov    0x8(%ebp),%eax
c010b018:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b01b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b01e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010b021:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b024:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b027:	89 d1                	mov    %edx,%ecx
c010b029:	89 c2                	mov    %eax,%edx
c010b02b:	89 ce                	mov    %ecx,%esi
c010b02d:	89 d7                	mov    %edx,%edi
c010b02f:	ac                   	lods   %ds:(%esi),%al
c010b030:	aa                   	stos   %al,%es:(%edi)
c010b031:	84 c0                	test   %al,%al
c010b033:	75 fa                	jne    c010b02f <strcpy+0x22>
c010b035:	89 fa                	mov    %edi,%edx
c010b037:	89 f1                	mov    %esi,%ecx
c010b039:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b03c:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b03f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010b042:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010b045:	83 c4 20             	add    $0x20,%esp
c010b048:	5e                   	pop    %esi
c010b049:	5f                   	pop    %edi
c010b04a:	5d                   	pop    %ebp
c010b04b:	c3                   	ret    

c010b04c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010b04c:	55                   	push   %ebp
c010b04d:	89 e5                	mov    %esp,%ebp
c010b04f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010b052:	8b 45 08             	mov    0x8(%ebp),%eax
c010b055:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010b058:	eb 21                	jmp    c010b07b <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010b05a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b05d:	0f b6 10             	movzbl (%eax),%edx
c010b060:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b063:	88 10                	mov    %dl,(%eax)
c010b065:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b068:	0f b6 00             	movzbl (%eax),%eax
c010b06b:	84 c0                	test   %al,%al
c010b06d:	74 04                	je     c010b073 <strncpy+0x27>
            src ++;
c010b06f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010b073:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b077:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c010b07b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b07f:	75 d9                	jne    c010b05a <strncpy+0xe>
    }
    return dst;
c010b081:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b084:	c9                   	leave  
c010b085:	c3                   	ret    

c010b086 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010b086:	55                   	push   %ebp
c010b087:	89 e5                	mov    %esp,%ebp
c010b089:	57                   	push   %edi
c010b08a:	56                   	push   %esi
c010b08b:	83 ec 20             	sub    $0x20,%esp
c010b08e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b091:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b094:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b097:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010b09a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b09d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b0a0:	89 d1                	mov    %edx,%ecx
c010b0a2:	89 c2                	mov    %eax,%edx
c010b0a4:	89 ce                	mov    %ecx,%esi
c010b0a6:	89 d7                	mov    %edx,%edi
c010b0a8:	ac                   	lods   %ds:(%esi),%al
c010b0a9:	ae                   	scas   %es:(%edi),%al
c010b0aa:	75 08                	jne    c010b0b4 <strcmp+0x2e>
c010b0ac:	84 c0                	test   %al,%al
c010b0ae:	75 f8                	jne    c010b0a8 <strcmp+0x22>
c010b0b0:	31 c0                	xor    %eax,%eax
c010b0b2:	eb 04                	jmp    c010b0b8 <strcmp+0x32>
c010b0b4:	19 c0                	sbb    %eax,%eax
c010b0b6:	0c 01                	or     $0x1,%al
c010b0b8:	89 fa                	mov    %edi,%edx
c010b0ba:	89 f1                	mov    %esi,%ecx
c010b0bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b0bf:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b0c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010b0c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b0c8:	83 c4 20             	add    $0x20,%esp
c010b0cb:	5e                   	pop    %esi
c010b0cc:	5f                   	pop    %edi
c010b0cd:	5d                   	pop    %ebp
c010b0ce:	c3                   	ret    

c010b0cf <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b0cf:	55                   	push   %ebp
c010b0d0:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b0d2:	eb 0c                	jmp    c010b0e0 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010b0d4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b0d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b0dc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b0e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b0e4:	74 1a                	je     c010b100 <strncmp+0x31>
c010b0e6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0e9:	0f b6 00             	movzbl (%eax),%eax
c010b0ec:	84 c0                	test   %al,%al
c010b0ee:	74 10                	je     c010b100 <strncmp+0x31>
c010b0f0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0f3:	0f b6 10             	movzbl (%eax),%edx
c010b0f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0f9:	0f b6 00             	movzbl (%eax),%eax
c010b0fc:	38 c2                	cmp    %al,%dl
c010b0fe:	74 d4                	je     c010b0d4 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b100:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b104:	74 18                	je     c010b11e <strncmp+0x4f>
c010b106:	8b 45 08             	mov    0x8(%ebp),%eax
c010b109:	0f b6 00             	movzbl (%eax),%eax
c010b10c:	0f b6 d0             	movzbl %al,%edx
c010b10f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b112:	0f b6 00             	movzbl (%eax),%eax
c010b115:	0f b6 c8             	movzbl %al,%ecx
c010b118:	89 d0                	mov    %edx,%eax
c010b11a:	29 c8                	sub    %ecx,%eax
c010b11c:	eb 05                	jmp    c010b123 <strncmp+0x54>
c010b11e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b123:	5d                   	pop    %ebp
c010b124:	c3                   	ret    

c010b125 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b125:	55                   	push   %ebp
c010b126:	89 e5                	mov    %esp,%ebp
c010b128:	83 ec 04             	sub    $0x4,%esp
c010b12b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b12e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b131:	eb 14                	jmp    c010b147 <strchr+0x22>
        if (*s == c) {
c010b133:	8b 45 08             	mov    0x8(%ebp),%eax
c010b136:	0f b6 00             	movzbl (%eax),%eax
c010b139:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b13c:	75 05                	jne    c010b143 <strchr+0x1e>
            return (char *)s;
c010b13e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b141:	eb 13                	jmp    c010b156 <strchr+0x31>
        }
        s ++;
c010b143:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b147:	8b 45 08             	mov    0x8(%ebp),%eax
c010b14a:	0f b6 00             	movzbl (%eax),%eax
c010b14d:	84 c0                	test   %al,%al
c010b14f:	75 e2                	jne    c010b133 <strchr+0xe>
    }
    return NULL;
c010b151:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b156:	c9                   	leave  
c010b157:	c3                   	ret    

c010b158 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b158:	55                   	push   %ebp
c010b159:	89 e5                	mov    %esp,%ebp
c010b15b:	83 ec 04             	sub    $0x4,%esp
c010b15e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b161:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b164:	eb 0f                	jmp    c010b175 <strfind+0x1d>
        if (*s == c) {
c010b166:	8b 45 08             	mov    0x8(%ebp),%eax
c010b169:	0f b6 00             	movzbl (%eax),%eax
c010b16c:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b16f:	74 10                	je     c010b181 <strfind+0x29>
            break;
        }
        s ++;
c010b171:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010b175:	8b 45 08             	mov    0x8(%ebp),%eax
c010b178:	0f b6 00             	movzbl (%eax),%eax
c010b17b:	84 c0                	test   %al,%al
c010b17d:	75 e7                	jne    c010b166 <strfind+0xe>
c010b17f:	eb 01                	jmp    c010b182 <strfind+0x2a>
            break;
c010b181:	90                   	nop
    }
    return (char *)s;
c010b182:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b185:	c9                   	leave  
c010b186:	c3                   	ret    

c010b187 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b187:	55                   	push   %ebp
c010b188:	89 e5                	mov    %esp,%ebp
c010b18a:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010b18d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b194:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b19b:	eb 04                	jmp    c010b1a1 <strtol+0x1a>
        s ++;
c010b19d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010b1a1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1a4:	0f b6 00             	movzbl (%eax),%eax
c010b1a7:	3c 20                	cmp    $0x20,%al
c010b1a9:	74 f2                	je     c010b19d <strtol+0x16>
c010b1ab:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1ae:	0f b6 00             	movzbl (%eax),%eax
c010b1b1:	3c 09                	cmp    $0x9,%al
c010b1b3:	74 e8                	je     c010b19d <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c010b1b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1b8:	0f b6 00             	movzbl (%eax),%eax
c010b1bb:	3c 2b                	cmp    $0x2b,%al
c010b1bd:	75 06                	jne    c010b1c5 <strtol+0x3e>
        s ++;
c010b1bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b1c3:	eb 15                	jmp    c010b1da <strtol+0x53>
    }
    else if (*s == '-') {
c010b1c5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1c8:	0f b6 00             	movzbl (%eax),%eax
c010b1cb:	3c 2d                	cmp    $0x2d,%al
c010b1cd:	75 0b                	jne    c010b1da <strtol+0x53>
        s ++, neg = 1;
c010b1cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b1d3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b1da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b1de:	74 06                	je     c010b1e6 <strtol+0x5f>
c010b1e0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b1e4:	75 24                	jne    c010b20a <strtol+0x83>
c010b1e6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1e9:	0f b6 00             	movzbl (%eax),%eax
c010b1ec:	3c 30                	cmp    $0x30,%al
c010b1ee:	75 1a                	jne    c010b20a <strtol+0x83>
c010b1f0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1f3:	83 c0 01             	add    $0x1,%eax
c010b1f6:	0f b6 00             	movzbl (%eax),%eax
c010b1f9:	3c 78                	cmp    $0x78,%al
c010b1fb:	75 0d                	jne    c010b20a <strtol+0x83>
        s += 2, base = 16;
c010b1fd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b201:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b208:	eb 2a                	jmp    c010b234 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010b20a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b20e:	75 17                	jne    c010b227 <strtol+0xa0>
c010b210:	8b 45 08             	mov    0x8(%ebp),%eax
c010b213:	0f b6 00             	movzbl (%eax),%eax
c010b216:	3c 30                	cmp    $0x30,%al
c010b218:	75 0d                	jne    c010b227 <strtol+0xa0>
        s ++, base = 8;
c010b21a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b21e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b225:	eb 0d                	jmp    c010b234 <strtol+0xad>
    }
    else if (base == 0) {
c010b227:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b22b:	75 07                	jne    c010b234 <strtol+0xad>
        base = 10;
c010b22d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b234:	8b 45 08             	mov    0x8(%ebp),%eax
c010b237:	0f b6 00             	movzbl (%eax),%eax
c010b23a:	3c 2f                	cmp    $0x2f,%al
c010b23c:	7e 1b                	jle    c010b259 <strtol+0xd2>
c010b23e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b241:	0f b6 00             	movzbl (%eax),%eax
c010b244:	3c 39                	cmp    $0x39,%al
c010b246:	7f 11                	jg     c010b259 <strtol+0xd2>
            dig = *s - '0';
c010b248:	8b 45 08             	mov    0x8(%ebp),%eax
c010b24b:	0f b6 00             	movzbl (%eax),%eax
c010b24e:	0f be c0             	movsbl %al,%eax
c010b251:	83 e8 30             	sub    $0x30,%eax
c010b254:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b257:	eb 48                	jmp    c010b2a1 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b259:	8b 45 08             	mov    0x8(%ebp),%eax
c010b25c:	0f b6 00             	movzbl (%eax),%eax
c010b25f:	3c 60                	cmp    $0x60,%al
c010b261:	7e 1b                	jle    c010b27e <strtol+0xf7>
c010b263:	8b 45 08             	mov    0x8(%ebp),%eax
c010b266:	0f b6 00             	movzbl (%eax),%eax
c010b269:	3c 7a                	cmp    $0x7a,%al
c010b26b:	7f 11                	jg     c010b27e <strtol+0xf7>
            dig = *s - 'a' + 10;
c010b26d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b270:	0f b6 00             	movzbl (%eax),%eax
c010b273:	0f be c0             	movsbl %al,%eax
c010b276:	83 e8 57             	sub    $0x57,%eax
c010b279:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b27c:	eb 23                	jmp    c010b2a1 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b27e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b281:	0f b6 00             	movzbl (%eax),%eax
c010b284:	3c 40                	cmp    $0x40,%al
c010b286:	7e 3c                	jle    c010b2c4 <strtol+0x13d>
c010b288:	8b 45 08             	mov    0x8(%ebp),%eax
c010b28b:	0f b6 00             	movzbl (%eax),%eax
c010b28e:	3c 5a                	cmp    $0x5a,%al
c010b290:	7f 32                	jg     c010b2c4 <strtol+0x13d>
            dig = *s - 'A' + 10;
c010b292:	8b 45 08             	mov    0x8(%ebp),%eax
c010b295:	0f b6 00             	movzbl (%eax),%eax
c010b298:	0f be c0             	movsbl %al,%eax
c010b29b:	83 e8 37             	sub    $0x37,%eax
c010b29e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b2a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2a4:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b2a7:	7d 1a                	jge    c010b2c3 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c010b2a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b2ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b2b0:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b2b4:	89 c2                	mov    %eax,%edx
c010b2b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2b9:	01 d0                	add    %edx,%eax
c010b2bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010b2be:	e9 71 ff ff ff       	jmp    c010b234 <strtol+0xad>
            break;
c010b2c3:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010b2c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b2c8:	74 08                	je     c010b2d2 <strtol+0x14b>
        *endptr = (char *) s;
c010b2ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2cd:	8b 55 08             	mov    0x8(%ebp),%edx
c010b2d0:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b2d2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b2d6:	74 07                	je     c010b2df <strtol+0x158>
c010b2d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b2db:	f7 d8                	neg    %eax
c010b2dd:	eb 03                	jmp    c010b2e2 <strtol+0x15b>
c010b2df:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b2e2:	c9                   	leave  
c010b2e3:	c3                   	ret    

c010b2e4 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b2e4:	55                   	push   %ebp
c010b2e5:	89 e5                	mov    %esp,%ebp
c010b2e7:	57                   	push   %edi
c010b2e8:	83 ec 24             	sub    $0x24,%esp
c010b2eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2ee:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b2f1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010b2f5:	8b 55 08             	mov    0x8(%ebp),%edx
c010b2f8:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010b2fb:	88 45 f7             	mov    %al,-0x9(%ebp)
c010b2fe:	8b 45 10             	mov    0x10(%ebp),%eax
c010b301:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b304:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b307:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b30b:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b30e:	89 d7                	mov    %edx,%edi
c010b310:	f3 aa                	rep stos %al,%es:(%edi)
c010b312:	89 fa                	mov    %edi,%edx
c010b314:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b317:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b31a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b31d:	8b 7d fc             	mov    -0x4(%ebp),%edi
c010b320:	c9                   	leave  
c010b321:	c3                   	ret    

c010b322 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b322:	55                   	push   %ebp
c010b323:	89 e5                	mov    %esp,%ebp
c010b325:	57                   	push   %edi
c010b326:	56                   	push   %esi
c010b327:	53                   	push   %ebx
c010b328:	83 ec 30             	sub    $0x30,%esp
c010b32b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b32e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b331:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b334:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b337:	8b 45 10             	mov    0x10(%ebp),%eax
c010b33a:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010b33d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b340:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010b343:	73 42                	jae    c010b387 <memmove+0x65>
c010b345:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b348:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b34b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b34e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b351:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b354:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b357:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b35a:	c1 e8 02             	shr    $0x2,%eax
c010b35d:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b35f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b362:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b365:	89 d7                	mov    %edx,%edi
c010b367:	89 c6                	mov    %eax,%esi
c010b369:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b36b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010b36e:	83 e1 03             	and    $0x3,%ecx
c010b371:	74 02                	je     c010b375 <memmove+0x53>
c010b373:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b375:	89 f0                	mov    %esi,%eax
c010b377:	89 fa                	mov    %edi,%edx
c010b379:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010b37c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b37f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010b382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010b385:	eb 36                	jmp    c010b3bd <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010b387:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b38a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b38d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b390:	01 c2                	add    %eax,%edx
c010b392:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b395:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010b398:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b39b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010b39e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3a1:	89 c1                	mov    %eax,%ecx
c010b3a3:	89 d8                	mov    %ebx,%eax
c010b3a5:	89 d6                	mov    %edx,%esi
c010b3a7:	89 c7                	mov    %eax,%edi
c010b3a9:	fd                   	std    
c010b3aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b3ac:	fc                   	cld    
c010b3ad:	89 f8                	mov    %edi,%eax
c010b3af:	89 f2                	mov    %esi,%edx
c010b3b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010b3b4:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010b3b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010b3ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010b3bd:	83 c4 30             	add    $0x30,%esp
c010b3c0:	5b                   	pop    %ebx
c010b3c1:	5e                   	pop    %esi
c010b3c2:	5f                   	pop    %edi
c010b3c3:	5d                   	pop    %ebp
c010b3c4:	c3                   	ret    

c010b3c5 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010b3c5:	55                   	push   %ebp
c010b3c6:	89 e5                	mov    %esp,%ebp
c010b3c8:	57                   	push   %edi
c010b3c9:	56                   	push   %esi
c010b3ca:	83 ec 20             	sub    $0x20,%esp
c010b3cd:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b3d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b3d9:	8b 45 10             	mov    0x10(%ebp),%eax
c010b3dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b3df:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b3e2:	c1 e8 02             	shr    $0x2,%eax
c010b3e5:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010b3e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b3ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3ed:	89 d7                	mov    %edx,%edi
c010b3ef:	89 c6                	mov    %eax,%esi
c010b3f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b3f3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b3f6:	83 e1 03             	and    $0x3,%ecx
c010b3f9:	74 02                	je     c010b3fd <memcpy+0x38>
c010b3fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b3fd:	89 f0                	mov    %esi,%eax
c010b3ff:	89 fa                	mov    %edi,%edx
c010b401:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b404:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b407:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010b40a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010b40d:	83 c4 20             	add    $0x20,%esp
c010b410:	5e                   	pop    %esi
c010b411:	5f                   	pop    %edi
c010b412:	5d                   	pop    %ebp
c010b413:	c3                   	ret    

c010b414 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010b414:	55                   	push   %ebp
c010b415:	89 e5                	mov    %esp,%ebp
c010b417:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010b41a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b41d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010b420:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b423:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010b426:	eb 30                	jmp    c010b458 <memcmp+0x44>
        if (*s1 != *s2) {
c010b428:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b42b:	0f b6 10             	movzbl (%eax),%edx
c010b42e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b431:	0f b6 00             	movzbl (%eax),%eax
c010b434:	38 c2                	cmp    %al,%dl
c010b436:	74 18                	je     c010b450 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b438:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b43b:	0f b6 00             	movzbl (%eax),%eax
c010b43e:	0f b6 d0             	movzbl %al,%edx
c010b441:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b444:	0f b6 00             	movzbl (%eax),%eax
c010b447:	0f b6 c8             	movzbl %al,%ecx
c010b44a:	89 d0                	mov    %edx,%eax
c010b44c:	29 c8                	sub    %ecx,%eax
c010b44e:	eb 1a                	jmp    c010b46a <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010b450:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b454:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c010b458:	8b 45 10             	mov    0x10(%ebp),%eax
c010b45b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b45e:	89 55 10             	mov    %edx,0x10(%ebp)
c010b461:	85 c0                	test   %eax,%eax
c010b463:	75 c3                	jne    c010b428 <memcmp+0x14>
    }
    return 0;
c010b465:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b46a:	c9                   	leave  
c010b46b:	c3                   	ret    
