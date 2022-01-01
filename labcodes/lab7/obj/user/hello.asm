
obj/__user_hello.out:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  800020:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  800025:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  800028:	e8 cb 03 00 00       	call   8003f8 <umain>
1:  jmp 1b
  80002d:	eb fe                	jmp    80002d <_start+0xd>

0080002f <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  80002f:	55                   	push   %ebp
  800030:	89 e5                	mov    %esp,%ebp
  800032:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800035:	8d 45 14             	lea    0x14(%ebp),%eax
  800038:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80003b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80003e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800042:	8b 45 08             	mov    0x8(%ebp),%eax
  800045:	89 44 24 04          	mov    %eax,0x4(%esp)
  800049:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  800050:	e8 cb 00 00 00       	call   800120 <cprintf>
    vcprintf(fmt, ap);
  800055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	8b 45 10             	mov    0x10(%ebp),%eax
  80005f:	89 04 24             	mov    %eax,(%esp)
  800062:	e8 84 00 00 00       	call   8000eb <vcprintf>
    cprintf("\n");
  800067:	c7 04 24 9a 10 80 00 	movl   $0x80109a,(%esp)
  80006e:	e8 ad 00 00 00       	call   800120 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800073:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80007a:	e8 93 02 00 00       	call   800312 <exit>

0080007f <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  800085:	8d 45 14             	lea    0x14(%ebp),%eax
  800088:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  80008b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800092:	8b 45 08             	mov    0x8(%ebp),%eax
  800095:	89 44 24 04          	mov    %eax,0x4(%esp)
  800099:	c7 04 24 9c 10 80 00 	movl   $0x80109c,(%esp)
  8000a0:	e8 7b 00 00 00       	call   800120 <cprintf>
    vcprintf(fmt, ap);
  8000a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8000af:	89 04 24             	mov    %eax,(%esp)
  8000b2:	e8 34 00 00 00       	call   8000eb <vcprintf>
    cprintf("\n");
  8000b7:	c7 04 24 9a 10 80 00 	movl   $0x80109a,(%esp)
  8000be:	e8 5d 00 00 00       	call   800120 <cprintf>
    va_end(ap);
}
  8000c3:	90                   	nop
  8000c4:	89 ec                	mov    %ebp,%esp
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8000ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d1:	89 04 24             	mov    %eax,(%esp)
  8000d4:	e8 b5 01 00 00       	call   80028e <sys_putc>
    (*cnt) ++;
  8000d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000dc:	8b 00                	mov    (%eax),%eax
  8000de:	8d 50 01             	lea    0x1(%eax),%edx
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	89 10                	mov    %edx,(%eax)
}
  8000e6:	90                   	nop
  8000e7:	89 ec                	mov    %ebp,%esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8000f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800102:	89 44 24 08          	mov    %eax,0x8(%esp)
  800106:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800109:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010d:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800114:	e8 e8 04 00 00       	call   800601 <vprintfmt>
    return cnt;
  800119:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80011c:	89 ec                	mov    %ebp,%esp
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800126:	8d 45 0c             	lea    0xc(%ebp),%eax
  800129:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  80012c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80012f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800133:	8b 45 08             	mov    0x8(%ebp),%eax
  800136:	89 04 24             	mov    %eax,(%esp)
  800139:	e8 ad ff ff ff       	call   8000eb <vcprintf>
  80013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800141:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800144:	89 ec                	mov    %ebp,%esp
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  80014e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800155:	eb 13                	jmp    80016a <cputs+0x22>
        cputch(c, &cnt);
  800157:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80015b:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80015e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800162:	89 04 24             	mov    %eax,(%esp)
  800165:	e8 5e ff ff ff       	call   8000c8 <cputch>
    while ((c = *str ++) != '\0') {
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8d 50 01             	lea    0x1(%eax),%edx
  800170:	89 55 08             	mov    %edx,0x8(%ebp)
  800173:	0f b6 00             	movzbl (%eax),%eax
  800176:	88 45 f7             	mov    %al,-0x9(%ebp)
  800179:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  80017d:	75 d8                	jne    800157 <cputs+0xf>
    }
    cputch('\n', &cnt);
  80017f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800182:	89 44 24 04          	mov    %eax,0x4(%esp)
  800186:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80018d:	e8 36 ff ff ff       	call   8000c8 <cputch>
    return cnt;
  800192:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800195:	89 ec                	mov    %ebp,%esp
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8001a2:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8001a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8001af:	eb 15                	jmp    8001c6 <syscall+0x2d>
        a[i] = va_arg(ap, uint32_t);
  8001b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8001b4:	8d 50 04             	lea    0x4(%eax),%edx
  8001b7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001ba:	8b 10                	mov    (%eax),%edx
  8001bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001bf:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
    for (i = 0; i < MAX_ARGS; i ++) {
  8001c3:	ff 45 f0             	incl   -0x10(%ebp)
  8001c6:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8001ca:	7e e5                	jle    8001b1 <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8001cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8001cf:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8001d2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8001d5:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8001d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    asm volatile (
  8001db:	8b 45 08             	mov    0x8(%ebp),%eax
  8001de:	cd 80                	int    $0x80
  8001e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "cc", "memory");
    return ret;
  8001e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  8001e6:	83 c4 20             	add    $0x20,%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5f                   	pop    %edi
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <sys_exit>:

int
sys_exit(int error_code) {
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  8001f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800202:	e8 92 ff ff ff       	call   800199 <syscall>
}
  800207:	89 ec                	mov    %ebp,%esp
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <sys_fork>:

int
sys_fork(void) {
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  800211:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800218:	e8 7c ff ff ff       	call   800199 <syscall>
}
  80021d:	89 ec                	mov    %ebp,%esp
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_wait>:

int
sys_wait(int pid, int *store) {
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  800227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80023c:	e8 58 ff ff ff       	call   800199 <syscall>
}
  800241:	89 ec                	mov    %ebp,%esp
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    

00800245 <sys_yield>:

int
sys_yield(void) {
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  80024b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800252:	e8 42 ff ff ff       	call   800199 <syscall>
}
  800257:	89 ec                	mov    %ebp,%esp
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_kill>:

int
sys_kill(int pid) {
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80026f:	e8 25 ff ff ff       	call   800199 <syscall>
}
  800274:	89 ec                	mov    %ebp,%esp
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sys_getpid>:

int
sys_getpid(void) {
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  80027e:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  800285:	e8 0f ff ff ff       	call   800199 <syscall>
}
  80028a:	89 ec                	mov    %ebp,%esp
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <sys_putc>:

int
sys_putc(int c) {
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029b:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  8002a2:	e8 f2 fe ff ff       	call   800199 <syscall>
}
  8002a7:	89 ec                	mov    %ebp,%esp
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <sys_pgdir>:

int
sys_pgdir(void) {
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  8002b1:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  8002b8:	e8 dc fe ff ff       	call   800199 <syscall>
}
  8002bd:	89 ec                	mov    %ebp,%esp
  8002bf:	5d                   	pop    %ebp
  8002c0:	c3                   	ret    

008002c1 <sys_gettime>:

int
sys_gettime(void) {
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_gettime);
  8002c7:	c7 04 24 11 00 00 00 	movl   $0x11,(%esp)
  8002ce:	e8 c6 fe ff ff       	call   800199 <syscall>
}
  8002d3:	89 ec                	mov    %ebp,%esp
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 08             	sub    $0x8,%esp
    syscall(SYS_lab6_set_priority, priority);
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e4:	c7 04 24 ff 00 00 00 	movl   $0xff,(%esp)
  8002eb:	e8 a9 fe ff ff       	call   800199 <syscall>
}
  8002f0:	90                   	nop
  8002f1:	89 ec                	mov    %ebp,%esp
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sys_sleep>:

int
sys_sleep(unsigned int time) {
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_sleep, time);
  8002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800302:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  800309:	e8 8b fe ff ff       	call   800199 <syscall>
}
  80030e:	89 ec                	mov    %ebp,%esp
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  800318:	8b 45 08             	mov    0x8(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	e8 cb fe ff ff       	call   8001ee <sys_exit>
    cprintf("BUG: exit failed.\n");
  800323:	c7 04 24 b8 10 80 00 	movl   $0x8010b8,(%esp)
  80032a:	e8 f1 fd ff ff       	call   800120 <cprintf>
    while (1);
  80032f:	eb fe                	jmp    80032f <exit+0x1d>

00800331 <fork>:
}

int
fork(void) {
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  800337:	e8 cf fe ff ff       	call   80020b <sys_fork>
}
  80033c:	89 ec                	mov    %ebp,%esp
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <wait>:

int
wait(void) {
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800346:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80034d:	00 
  80034e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800355:	e8 c7 fe ff ff       	call   800221 <sys_wait>
}
  80035a:	89 ec                	mov    %ebp,%esp
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <waitpid>:

int
waitpid(int pid, int *store) {
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
  800367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	e8 ab fe ff ff       	call   800221 <sys_wait>
}
  800376:	89 ec                	mov    %ebp,%esp
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <yield>:

void
yield(void) {
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800380:	e8 c0 fe ff ff       	call   800245 <sys_yield>
}
  800385:	90                   	nop
  800386:	89 ec                	mov    %ebp,%esp
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <kill>:

int
kill(int pid) {
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	e8 c0 fe ff ff       	call   80025b <sys_kill>
}
  80039b:	89 ec                	mov    %ebp,%esp
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <getpid>:

int
getpid(void) {
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  8003a5:	e8 ce fe ff ff       	call   800278 <sys_getpid>
}
  8003aa:	89 ec                	mov    %ebp,%esp
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  8003b4:	e8 f2 fe ff ff       	call   8002ab <sys_pgdir>
}
  8003b9:	90                   	nop
  8003ba:	89 ec                	mov    %ebp,%esp
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    

008003be <gettime_msec>:

unsigned int
gettime_msec(void) {
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  8003c4:	e8 f8 fe ff ff       	call   8002c1 <sys_gettime>
}
  8003c9:	89 ec                	mov    %ebp,%esp
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	89 04 24             	mov    %eax,(%esp)
  8003d9:	e8 f9 fe ff ff       	call   8002d7 <sys_lab6_set_priority>
}
  8003de:	90                   	nop
  8003df:	89 ec                	mov    %ebp,%esp
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <sleep>:

int
sleep(unsigned int time) {
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	83 ec 18             	sub    $0x18,%esp
    return sys_sleep(time);
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	e8 01 ff ff ff       	call   8002f5 <sys_sleep>
}
  8003f4:	89 ec                	mov    %ebp,%esp
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  8003fe:	e8 37 0c 00 00       	call   80103a <main>
  800403:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  800406:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	e8 01 ff ff ff       	call   800312 <exit>

00800411 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
  80041a:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800420:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800423:	b8 20 00 00 00       	mov    $0x20,%eax
  800428:	2b 45 0c             	sub    0xc(%ebp),%eax
  80042b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80042e:	88 c1                	mov    %al,%cl
  800430:	d3 ea                	shr    %cl,%edx
  800432:	89 d0                	mov    %edx,%eax
}
  800434:	89 ec                	mov    %ebp,%esp
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 58             	sub    $0x58,%esp
  80043e:	8b 45 10             	mov    0x10(%ebp),%eax
  800441:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  80044a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800450:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800453:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800456:	8b 45 18             	mov    0x18(%ebp),%eax
  800459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80045f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800468:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80046b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80046e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800472:	74 1c                	je     800490 <printnum+0x58>
  800474:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800477:	ba 00 00 00 00       	mov    $0x0,%edx
  80047c:	f7 75 e4             	divl   -0x1c(%ebp)
  80047f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800485:	ba 00 00 00 00       	mov    $0x0,%edx
  80048a:	f7 75 e4             	divl   -0x1c(%ebp)
  80048d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800490:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800493:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800496:	f7 75 e4             	divl   -0x1c(%ebp)
  800499:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80049f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8004a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8004a8:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8004ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ae:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8004b1:	8b 45 18             	mov    0x18(%ebp),%eax
  8004b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004bc:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  8004bf:	19 d1                	sbb    %edx,%ecx
  8004c1:	72 4c                	jb     80050f <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  8004c3:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8004c6:	8d 50 ff             	lea    -0x1(%eax),%edx
  8004c9:	8b 45 20             	mov    0x20(%ebp),%eax
  8004cc:	89 44 24 18          	mov    %eax,0x18(%esp)
  8004d0:	89 54 24 14          	mov    %edx,0x14(%esp)
  8004d4:	8b 45 18             	mov    0x18(%ebp),%eax
  8004d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004db:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8004de:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8004e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f3:	89 04 24             	mov    %eax,(%esp)
  8004f6:	e8 3d ff ff ff       	call   800438 <printnum>
  8004fb:	eb 1b                	jmp    800518 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	8b 45 20             	mov    0x20(%ebp),%eax
  800507:	89 04 24             	mov    %eax,(%esp)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	ff d0                	call   *%eax
        while (-- width > 0)
  80050f:	ff 4d 1c             	decl   0x1c(%ebp)
  800512:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800516:	7f e5                	jg     8004fd <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800518:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80051b:	05 e4 11 80 00       	add    $0x8011e4,%eax
  800520:	0f b6 00             	movzbl (%eax),%eax
  800523:	0f be c0             	movsbl %al,%eax
  800526:	8b 55 0c             	mov    0xc(%ebp),%edx
  800529:	89 54 24 04          	mov    %edx,0x4(%esp)
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	8b 45 08             	mov    0x8(%ebp),%eax
  800533:	ff d0                	call   *%eax
}
  800535:	90                   	nop
  800536:	89 ec                	mov    %ebp,%esp
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    

0080053a <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80053d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800541:	7e 14                	jle    800557 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800543:	8b 45 08             	mov    0x8(%ebp),%eax
  800546:	8b 00                	mov    (%eax),%eax
  800548:	8d 48 08             	lea    0x8(%eax),%ecx
  80054b:	8b 55 08             	mov    0x8(%ebp),%edx
  80054e:	89 0a                	mov    %ecx,(%edx)
  800550:	8b 50 04             	mov    0x4(%eax),%edx
  800553:	8b 00                	mov    (%eax),%eax
  800555:	eb 30                	jmp    800587 <getuint+0x4d>
    }
    else if (lflag) {
  800557:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80055b:	74 16                	je     800573 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	8d 48 04             	lea    0x4(%eax),%ecx
  800565:	8b 55 08             	mov    0x8(%ebp),%edx
  800568:	89 0a                	mov    %ecx,(%edx)
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	ba 00 00 00 00       	mov    $0x0,%edx
  800571:	eb 14                	jmp    800587 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800573:	8b 45 08             	mov    0x8(%ebp),%eax
  800576:	8b 00                	mov    (%eax),%eax
  800578:	8d 48 04             	lea    0x4(%eax),%ecx
  80057b:	8b 55 08             	mov    0x8(%ebp),%edx
  80057e:	89 0a                	mov    %ecx,(%edx)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800587:	5d                   	pop    %ebp
  800588:	c3                   	ret    

00800589 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80058c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800590:	7e 14                	jle    8005a6 <getint+0x1d>
        return va_arg(*ap, long long);
  800592:	8b 45 08             	mov    0x8(%ebp),%eax
  800595:	8b 00                	mov    (%eax),%eax
  800597:	8d 48 08             	lea    0x8(%eax),%ecx
  80059a:	8b 55 08             	mov    0x8(%ebp),%edx
  80059d:	89 0a                	mov    %ecx,(%edx)
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	eb 28                	jmp    8005ce <getint+0x45>
    }
    else if (lflag) {
  8005a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8005aa:	74 12                	je     8005be <getint+0x35>
        return va_arg(*ap, long);
  8005ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b7:	89 0a                	mov    %ecx,(%edx)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	99                   	cltd   
  8005bc:	eb 10                	jmp    8005ce <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c9:	89 0a                	mov    %ecx,(%edx)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	99                   	cltd   
    }
}
  8005ce:	5d                   	pop    %ebp
  8005cf:	c3                   	ret    

008005d0 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  8005dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	e8 05 00 00 00       	call   800601 <vprintfmt>
    va_end(ap);
}
  8005fc:	90                   	nop
  8005fd:	89 ec                	mov    %ebp,%esp
  8005ff:	5d                   	pop    %ebp
  800600:	c3                   	ret    

00800601 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	56                   	push   %esi
  800605:	53                   	push   %ebx
  800606:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800609:	eb 17                	jmp    800622 <vprintfmt+0x21>
            if (ch == '\0') {
  80060b:	85 db                	test   %ebx,%ebx
  80060d:	0f 84 bf 03 00 00    	je     8009d2 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  800613:	8b 45 0c             	mov    0xc(%ebp),%eax
  800616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061a:	89 1c 24             	mov    %ebx,(%esp)
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800622:	8b 45 10             	mov    0x10(%ebp),%eax
  800625:	8d 50 01             	lea    0x1(%eax),%edx
  800628:	89 55 10             	mov    %edx,0x10(%ebp)
  80062b:	0f b6 00             	movzbl (%eax),%eax
  80062e:	0f b6 d8             	movzbl %al,%ebx
  800631:	83 fb 25             	cmp    $0x25,%ebx
  800634:	75 d5                	jne    80060b <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800636:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  80063a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800644:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800647:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80064e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800651:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800654:	8b 45 10             	mov    0x10(%ebp),%eax
  800657:	8d 50 01             	lea    0x1(%eax),%edx
  80065a:	89 55 10             	mov    %edx,0x10(%ebp)
  80065d:	0f b6 00             	movzbl (%eax),%eax
  800660:	0f b6 d8             	movzbl %al,%ebx
  800663:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800666:	83 f8 55             	cmp    $0x55,%eax
  800669:	0f 87 37 03 00 00    	ja     8009a6 <vprintfmt+0x3a5>
  80066f:	8b 04 85 08 12 80 00 	mov    0x801208(,%eax,4),%eax
  800676:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800678:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  80067c:	eb d6                	jmp    800654 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  80067e:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800682:	eb d0                	jmp    800654 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800684:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  80068b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068e:	89 d0                	mov    %edx,%eax
  800690:	c1 e0 02             	shl    $0x2,%eax
  800693:	01 d0                	add    %edx,%eax
  800695:	01 c0                	add    %eax,%eax
  800697:	01 d8                	add    %ebx,%eax
  800699:	83 e8 30             	sub    $0x30,%eax
  80069c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  80069f:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a2:	0f b6 00             	movzbl (%eax),%eax
  8006a5:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  8006a8:	83 fb 2f             	cmp    $0x2f,%ebx
  8006ab:	7e 38                	jle    8006e5 <vprintfmt+0xe4>
  8006ad:	83 fb 39             	cmp    $0x39,%ebx
  8006b0:	7f 33                	jg     8006e5 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  8006b2:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  8006b5:	eb d4                	jmp    80068b <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  8006c5:	eb 1f                	jmp    8006e6 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  8006c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006cb:	79 87                	jns    800654 <vprintfmt+0x53>
                width = 0;
  8006cd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  8006d4:	e9 7b ff ff ff       	jmp    800654 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  8006d9:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  8006e0:	e9 6f ff ff ff       	jmp    800654 <vprintfmt+0x53>
            goto process_precision;
  8006e5:	90                   	nop

        process_precision:
            if (width < 0)
  8006e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006ea:	0f 89 64 ff ff ff    	jns    800654 <vprintfmt+0x53>
                width = precision, precision = -1;
  8006f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8006f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  8006fd:	e9 52 ff ff ff       	jmp    800654 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800702:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  800705:	e9 4a ff ff ff       	jmp    800654 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 00                	mov    (%eax),%eax
  800715:	8b 55 0c             	mov    0xc(%ebp),%edx
  800718:	89 54 24 04          	mov    %edx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	ff d0                	call   *%eax
            break;
  800724:	e9 a4 02 00 00       	jmp    8009cd <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8d 50 04             	lea    0x4(%eax),%edx
  80072f:	89 55 14             	mov    %edx,0x14(%ebp)
  800732:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800734:	85 db                	test   %ebx,%ebx
  800736:	79 02                	jns    80073a <vprintfmt+0x139>
                err = -err;
  800738:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80073a:	83 fb 18             	cmp    $0x18,%ebx
  80073d:	7f 0b                	jg     80074a <vprintfmt+0x149>
  80073f:	8b 34 9d 80 11 80 00 	mov    0x801180(,%ebx,4),%esi
  800746:	85 f6                	test   %esi,%esi
  800748:	75 23                	jne    80076d <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  80074a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80074e:	c7 44 24 08 f5 11 80 	movl   $0x8011f5,0x8(%esp)
  800755:	00 
  800756:	8b 45 0c             	mov    0xc(%ebp),%eax
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	e8 68 fe ff ff       	call   8005d0 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800768:	e9 60 02 00 00       	jmp    8009cd <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  80076d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800771:	c7 44 24 08 fe 11 80 	movl   $0x8011fe,0x8(%esp)
  800778:	00 
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	89 04 24             	mov    %eax,(%esp)
  800786:	e8 45 fe ff ff       	call   8005d0 <printfmt>
            break;
  80078b:	e9 3d 02 00 00       	jmp    8009cd <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 50 04             	lea    0x4(%eax),%edx
  800796:	89 55 14             	mov    %edx,0x14(%ebp)
  800799:	8b 30                	mov    (%eax),%esi
  80079b:	85 f6                	test   %esi,%esi
  80079d:	75 05                	jne    8007a4 <vprintfmt+0x1a3>
                p = "(null)";
  80079f:	be 01 12 80 00       	mov    $0x801201,%esi
            }
            if (width > 0 && padc != '-') {
  8007a4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8007a8:	7e 76                	jle    800820 <vprintfmt+0x21f>
  8007aa:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8007ae:	74 70                	je     800820 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8007b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b7:	89 34 24             	mov    %esi,(%esp)
  8007ba:	e8 ee 03 00 00       	call   800bad <strnlen>
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007c4:	29 d0                	sub    %edx,%eax
  8007c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8007c9:	eb 16                	jmp    8007e1 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  8007cb:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  8007de:	ff 4d e8             	decl   -0x18(%ebp)
  8007e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8007e5:	7f e4                	jg     8007cb <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8007e7:	eb 37                	jmp    800820 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  8007e9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ed:	74 1f                	je     80080e <vprintfmt+0x20d>
  8007ef:	83 fb 1f             	cmp    $0x1f,%ebx
  8007f2:	7e 05                	jle    8007f9 <vprintfmt+0x1f8>
  8007f4:	83 fb 7e             	cmp    $0x7e,%ebx
  8007f7:	7e 15                	jle    80080e <vprintfmt+0x20d>
                    putch('?', putdat);
  8007f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800800:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	ff d0                	call   *%eax
  80080c:	eb 0f                	jmp    80081d <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	89 1c 24             	mov    %ebx,(%esp)
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80081d:	ff 4d e8             	decl   -0x18(%ebp)
  800820:	89 f0                	mov    %esi,%eax
  800822:	8d 70 01             	lea    0x1(%eax),%esi
  800825:	0f b6 00             	movzbl (%eax),%eax
  800828:	0f be d8             	movsbl %al,%ebx
  80082b:	85 db                	test   %ebx,%ebx
  80082d:	74 27                	je     800856 <vprintfmt+0x255>
  80082f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800833:	78 b4                	js     8007e9 <vprintfmt+0x1e8>
  800835:	ff 4d e4             	decl   -0x1c(%ebp)
  800838:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80083c:	79 ab                	jns    8007e9 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  80083e:	eb 16                	jmp    800856 <vprintfmt+0x255>
                putch(' ', putdat);
  800840:	8b 45 0c             	mov    0xc(%ebp),%eax
  800843:	89 44 24 04          	mov    %eax,0x4(%esp)
  800847:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  800853:	ff 4d e8             	decl   -0x18(%ebp)
  800856:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80085a:	7f e4                	jg     800840 <vprintfmt+0x23f>
            }
            break;
  80085c:	e9 6c 01 00 00       	jmp    8009cd <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800861:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800864:	89 44 24 04          	mov    %eax,0x4(%esp)
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
  80086b:	89 04 24             	mov    %eax,(%esp)
  80086e:	e8 16 fd ff ff       	call   800589 <getint>
  800873:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800876:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80087f:	85 d2                	test   %edx,%edx
  800881:	79 26                	jns    8008a9 <vprintfmt+0x2a8>
                putch('-', putdat);
  800883:	8b 45 0c             	mov    0xc(%ebp),%eax
  800886:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	ff d0                	call   *%eax
                num = -(long long)num;
  800896:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800899:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80089c:	f7 d8                	neg    %eax
  80089e:	83 d2 00             	adc    $0x0,%edx
  8008a1:	f7 da                	neg    %edx
  8008a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  8008a9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  8008b0:	e9 a8 00 00 00       	jmp    80095d <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  8008b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8008bf:	89 04 24             	mov    %eax,(%esp)
  8008c2:	e8 73 fc ff ff       	call   80053a <getuint>
  8008c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  8008cd:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  8008d4:	e9 84 00 00 00       	jmp    80095d <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  8008d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e3:	89 04 24             	mov    %eax,(%esp)
  8008e6:	e8 4f fc ff ff       	call   80053a <getuint>
  8008eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ee:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  8008f1:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  8008f8:	eb 63                	jmp    80095d <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  8008fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	ff d0                	call   *%eax
            putch('x', putdat);
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	89 44 24 04          	mov    %eax,0x4(%esp)
  800914:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8d 50 04             	lea    0x4(%eax),%edx
  800926:	89 55 14             	mov    %edx,0x14(%ebp)
  800929:	8b 00                	mov    (%eax),%eax
  80092b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80092e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800935:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  80093c:	eb 1f                	jmp    80095d <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  80093e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800941:	89 44 24 04          	mov    %eax,0x4(%esp)
  800945:	8d 45 14             	lea    0x14(%ebp),%eax
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	e8 ea fb ff ff       	call   80053a <getuint>
  800950:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800953:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800956:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  80095d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800961:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800964:	89 54 24 18          	mov    %edx,0x18(%esp)
  800968:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80096b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80096f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800973:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800976:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800979:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	89 44 24 04          	mov    %eax,0x4(%esp)
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	e8 a5 fa ff ff       	call   800438 <printnum>
            break;
  800993:	eb 38                	jmp    8009cd <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099c:	89 1c 24             	mov    %ebx,(%esp)
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	ff d0                	call   *%eax
            break;
  8009a4:	eb 27                	jmp    8009cd <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  8009a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ad:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  8009b9:	ff 4d 10             	decl   0x10(%ebp)
  8009bc:	eb 03                	jmp    8009c1 <vprintfmt+0x3c0>
  8009be:	ff 4d 10             	decl   0x10(%ebp)
  8009c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c4:	48                   	dec    %eax
  8009c5:	0f b6 00             	movzbl (%eax),%eax
  8009c8:	3c 25                	cmp    $0x25,%al
  8009ca:	75 f2                	jne    8009be <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  8009cc:	90                   	nop
    while (1) {
  8009cd:	e9 37 fc ff ff       	jmp    800609 <vprintfmt+0x8>
                return;
  8009d2:	90                   	nop
        }
    }
}
  8009d3:	83 c4 40             	add    $0x40,%esp
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	8b 40 08             	mov    0x8(%eax),%eax
  8009e3:	8d 50 01             	lea    0x1(%eax),%edx
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e9:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	8b 10                	mov    (%eax),%edx
  8009f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f4:	8b 40 04             	mov    0x4(%eax),%eax
  8009f7:	39 c2                	cmp    %eax,%edx
  8009f9:	73 12                	jae    800a0d <sprintputch+0x33>
        *b->buf ++ = ch;
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	8b 00                	mov    (%eax),%eax
  800a00:	8d 48 01             	lea    0x1(%eax),%ecx
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a06:	89 0a                	mov    %ecx,(%edx)
  800a08:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0b:	88 10                	mov    %dl,(%eax)
    }
}
  800a0d:	90                   	nop
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800a16:	8d 45 14             	lea    0x14(%ebp),%eax
  800a19:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a23:	8b 45 10             	mov    0x10(%ebp),%eax
  800a26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	89 04 24             	mov    %eax,(%esp)
  800a37:	e8 0a 00 00 00       	call   800a46 <vsnprintf>
  800a3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a42:	89 ec                	mov    %ebp,%esp
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	01 d0                	add    %edx,%eax
  800a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800a67:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a6b:	74 0a                	je     800a77 <vsnprintf+0x31>
  800a6d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800a70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a73:	39 c2                	cmp    %eax,%edx
  800a75:	76 07                	jbe    800a7e <vsnprintf+0x38>
        return -E_INVAL;
  800a77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a7c:	eb 2a                	jmp    800aa8 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a85:	8b 45 10             	mov    0x10(%ebp),%eax
  800a88:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a93:	c7 04 24 da 09 80 00 	movl   $0x8009da,(%esp)
  800a9a:	e8 62 fb ff ff       	call   800601 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800a9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aa2:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800aa8:	89 ec                	mov    %ebp,%esp
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800ab5:	a1 00 20 80 00       	mov    0x802000,%eax
  800aba:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800ac0:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800ac6:	6b f0 05             	imul   $0x5,%eax,%esi
  800ac9:	01 fe                	add    %edi,%esi
  800acb:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  800ad0:	f7 e7                	mul    %edi
  800ad2:	01 d6                	add    %edx,%esi
  800ad4:	89 f2                	mov    %esi,%edx
  800ad6:	83 c0 0b             	add    $0xb,%eax
  800ad9:	83 d2 00             	adc    $0x0,%edx
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	83 e7 ff             	and    $0xffffffff,%edi
  800ae1:	89 f9                	mov    %edi,%ecx
  800ae3:	0f b7 da             	movzwl %dx,%ebx
  800ae6:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800aec:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800af2:	a1 00 20 80 00       	mov    0x802000,%eax
  800af7:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800afd:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800b01:	c1 ea 0c             	shr    $0xc,%edx
  800b04:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800b0a:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b17:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b27:	74 1c                	je     800b45 <rand+0x99>
  800b29:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	f7 75 dc             	divl   -0x24(%ebp)
  800b34:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800b37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	f7 75 dc             	divl   -0x24(%ebp)
  800b42:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b45:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b48:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b4b:	f7 75 dc             	divl   -0x24(%ebp)
  800b4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b51:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b54:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b57:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800b5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800b63:	83 c4 24             	add    $0x24,%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
    next = seed;
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	a3 00 20 80 00       	mov    %eax,0x802000
  800b7b:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800b81:	90                   	nop
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800b8a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  800b91:	eb 03                	jmp    800b96 <strlen+0x12>
        cnt ++;
  800b93:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  800b96:	8b 45 08             	mov    0x8(%ebp),%eax
  800b99:	8d 50 01             	lea    0x1(%eax),%edx
  800b9c:	89 55 08             	mov    %edx,0x8(%ebp)
  800b9f:	0f b6 00             	movzbl (%eax),%eax
  800ba2:	84 c0                	test   %al,%al
  800ba4:	75 ed                	jne    800b93 <strlen+0xf>
    }
    return cnt;
  800ba6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ba9:	89 ec                	mov    %ebp,%esp
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800bb3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800bba:	eb 03                	jmp    800bbf <strnlen+0x12>
        cnt ++;
  800bbc:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800bbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bc2:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800bc5:	73 10                	jae    800bd7 <strnlen+0x2a>
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	8d 50 01             	lea    0x1(%eax),%edx
  800bcd:	89 55 08             	mov    %edx,0x8(%ebp)
  800bd0:	0f b6 00             	movzbl (%eax),%eax
  800bd3:	84 c0                	test   %al,%al
  800bd5:	75 e5                	jne    800bbc <strnlen+0xf>
    }
    return cnt;
  800bd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800bda:	89 ec                	mov    %ebp,%esp
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	83 ec 20             	sub    $0x20,%esp
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800bec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bef:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800bf2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf8:	89 d1                	mov    %edx,%ecx
  800bfa:	89 c2                	mov    %eax,%edx
  800bfc:	89 ce                	mov    %ecx,%esi
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	ac                   	lods   %ds:(%esi),%al
  800c01:	aa                   	stos   %al,%es:(%edi)
  800c02:	84 c0                	test   %al,%al
  800c04:	75 fa                	jne    800c00 <strcpy+0x22>
  800c06:	89 fa                	mov    %edi,%edx
  800c08:	89 f1                	mov    %esi,%ecx
  800c0a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800c0d:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800c10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800c16:	83 c4 20             	add    $0x20,%esp
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800c23:	8b 45 08             	mov    0x8(%ebp),%eax
  800c26:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800c29:	eb 1e                	jmp    800c49 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	0f b6 10             	movzbl (%eax),%edx
  800c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c34:	88 10                	mov    %dl,(%eax)
  800c36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c39:	0f b6 00             	movzbl (%eax),%eax
  800c3c:	84 c0                	test   %al,%al
  800c3e:	74 03                	je     800c43 <strncpy+0x26>
            src ++;
  800c40:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  800c43:	ff 45 fc             	incl   -0x4(%ebp)
  800c46:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  800c49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c4d:	75 dc                	jne    800c2b <strncpy+0xe>
    }
    return dst;
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c52:	89 ec                	mov    %ebp,%esp
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	83 ec 20             	sub    $0x20,%esp
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c67:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  800c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c70:	89 d1                	mov    %edx,%ecx
  800c72:	89 c2                	mov    %eax,%edx
  800c74:	89 ce                	mov    %ecx,%esi
  800c76:	89 d7                	mov    %edx,%edi
  800c78:	ac                   	lods   %ds:(%esi),%al
  800c79:	ae                   	scas   %es:(%edi),%al
  800c7a:	75 08                	jne    800c84 <strcmp+0x2e>
  800c7c:	84 c0                	test   %al,%al
  800c7e:	75 f8                	jne    800c78 <strcmp+0x22>
  800c80:	31 c0                	xor    %eax,%eax
  800c82:	eb 04                	jmp    800c88 <strcmp+0x32>
  800c84:	19 c0                	sbb    %eax,%eax
  800c86:	0c 01                	or     $0x1,%al
  800c88:	89 fa                	mov    %edi,%edx
  800c8a:	89 f1                	mov    %esi,%ecx
  800c8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c8f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800c92:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  800c95:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  800c98:	83 c4 20             	add    $0x20,%esp
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800ca2:	eb 09                	jmp    800cad <strncmp+0xe>
        n --, s1 ++, s2 ++;
  800ca4:	ff 4d 10             	decl   0x10(%ebp)
  800ca7:	ff 45 08             	incl   0x8(%ebp)
  800caa:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800cad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb1:	74 1a                	je     800ccd <strncmp+0x2e>
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	0f b6 00             	movzbl (%eax),%eax
  800cb9:	84 c0                	test   %al,%al
  800cbb:	74 10                	je     800ccd <strncmp+0x2e>
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	0f b6 10             	movzbl (%eax),%edx
  800cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc6:	0f b6 00             	movzbl (%eax),%eax
  800cc9:	38 c2                	cmp    %al,%dl
  800ccb:	74 d7                	je     800ca4 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800ccd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cd1:	74 18                	je     800ceb <strncmp+0x4c>
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	0f b6 00             	movzbl (%eax),%eax
  800cd9:	0f b6 d0             	movzbl %al,%edx
  800cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdf:	0f b6 00             	movzbl (%eax),%eax
  800ce2:	0f b6 c8             	movzbl %al,%ecx
  800ce5:	89 d0                	mov    %edx,%eax
  800ce7:	29 c8                	sub    %ecx,%eax
  800ce9:	eb 05                	jmp    800cf0 <strncmp+0x51>
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 04             	sub    $0x4,%esp
  800cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfb:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800cfe:	eb 13                	jmp    800d13 <strchr+0x21>
        if (*s == c) {
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	0f b6 00             	movzbl (%eax),%eax
  800d06:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800d09:	75 05                	jne    800d10 <strchr+0x1e>
            return (char *)s;
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	eb 12                	jmp    800d22 <strchr+0x30>
        }
        s ++;
  800d10:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	0f b6 00             	movzbl (%eax),%eax
  800d19:	84 c0                	test   %al,%al
  800d1b:	75 e3                	jne    800d00 <strchr+0xe>
    }
    return NULL;
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d22:	89 ec                	mov    %ebp,%esp
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 04             	sub    $0x4,%esp
  800d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800d32:	eb 0e                	jmp    800d42 <strfind+0x1c>
        if (*s == c) {
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	0f b6 00             	movzbl (%eax),%eax
  800d3a:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800d3d:	74 0f                	je     800d4e <strfind+0x28>
            break;
        }
        s ++;
  800d3f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	0f b6 00             	movzbl (%eax),%eax
  800d48:	84 c0                	test   %al,%al
  800d4a:	75 e8                	jne    800d34 <strfind+0xe>
  800d4c:	eb 01                	jmp    800d4f <strfind+0x29>
            break;
  800d4e:	90                   	nop
    }
    return (char *)s;
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d52:	89 ec                	mov    %ebp,%esp
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800d5c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800d63:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800d6a:	eb 03                	jmp    800d6f <strtol+0x19>
        s ++;
  800d6c:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	0f b6 00             	movzbl (%eax),%eax
  800d75:	3c 20                	cmp    $0x20,%al
  800d77:	74 f3                	je     800d6c <strtol+0x16>
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	0f b6 00             	movzbl (%eax),%eax
  800d7f:	3c 09                	cmp    $0x9,%al
  800d81:	74 e9                	je     800d6c <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	3c 2b                	cmp    $0x2b,%al
  800d8b:	75 05                	jne    800d92 <strtol+0x3c>
        s ++;
  800d8d:	ff 45 08             	incl   0x8(%ebp)
  800d90:	eb 14                	jmp    800da6 <strtol+0x50>
    }
    else if (*s == '-') {
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	0f b6 00             	movzbl (%eax),%eax
  800d98:	3c 2d                	cmp    $0x2d,%al
  800d9a:	75 0a                	jne    800da6 <strtol+0x50>
        s ++, neg = 1;
  800d9c:	ff 45 08             	incl   0x8(%ebp)
  800d9f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  800da6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800daa:	74 06                	je     800db2 <strtol+0x5c>
  800dac:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800db0:	75 22                	jne    800dd4 <strtol+0x7e>
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	0f b6 00             	movzbl (%eax),%eax
  800db8:	3c 30                	cmp    $0x30,%al
  800dba:	75 18                	jne    800dd4 <strtol+0x7e>
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	40                   	inc    %eax
  800dc0:	0f b6 00             	movzbl (%eax),%eax
  800dc3:	3c 78                	cmp    $0x78,%al
  800dc5:	75 0d                	jne    800dd4 <strtol+0x7e>
        s += 2, base = 16;
  800dc7:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dcb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800dd2:	eb 29                	jmp    800dfd <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  800dd4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd8:	75 16                	jne    800df0 <strtol+0x9a>
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	3c 30                	cmp    $0x30,%al
  800de2:	75 0c                	jne    800df0 <strtol+0x9a>
        s ++, base = 8;
  800de4:	ff 45 08             	incl   0x8(%ebp)
  800de7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dee:	eb 0d                	jmp    800dfd <strtol+0xa7>
    }
    else if (base == 0) {
  800df0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df4:	75 07                	jne    800dfd <strtol+0xa7>
        base = 10;
  800df6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	0f b6 00             	movzbl (%eax),%eax
  800e03:	3c 2f                	cmp    $0x2f,%al
  800e05:	7e 1b                	jle    800e22 <strtol+0xcc>
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	0f b6 00             	movzbl (%eax),%eax
  800e0d:	3c 39                	cmp    $0x39,%al
  800e0f:	7f 11                	jg     800e22 <strtol+0xcc>
            dig = *s - '0';
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
  800e14:	0f b6 00             	movzbl (%eax),%eax
  800e17:	0f be c0             	movsbl %al,%eax
  800e1a:	83 e8 30             	sub    $0x30,%eax
  800e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e20:	eb 48                	jmp    800e6a <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	0f b6 00             	movzbl (%eax),%eax
  800e28:	3c 60                	cmp    $0x60,%al
  800e2a:	7e 1b                	jle    800e47 <strtol+0xf1>
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	0f b6 00             	movzbl (%eax),%eax
  800e32:	3c 7a                	cmp    $0x7a,%al
  800e34:	7f 11                	jg     800e47 <strtol+0xf1>
            dig = *s - 'a' + 10;
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	0f b6 00             	movzbl (%eax),%eax
  800e3c:	0f be c0             	movsbl %al,%eax
  800e3f:	83 e8 57             	sub    $0x57,%eax
  800e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e45:	eb 23                	jmp    800e6a <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	0f b6 00             	movzbl (%eax),%eax
  800e4d:	3c 40                	cmp    $0x40,%al
  800e4f:	7e 3b                	jle    800e8c <strtol+0x136>
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
  800e54:	0f b6 00             	movzbl (%eax),%eax
  800e57:	3c 5a                	cmp    $0x5a,%al
  800e59:	7f 31                	jg     800e8c <strtol+0x136>
            dig = *s - 'A' + 10;
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	0f b6 00             	movzbl (%eax),%eax
  800e61:	0f be c0             	movsbl %al,%eax
  800e64:	83 e8 37             	sub    $0x37,%eax
  800e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e70:	7d 19                	jge    800e8b <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  800e72:	ff 45 08             	incl   0x8(%ebp)
  800e75:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e7c:	89 c2                	mov    %eax,%edx
  800e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e81:	01 d0                	add    %edx,%eax
  800e83:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  800e86:	e9 72 ff ff ff       	jmp    800dfd <strtol+0xa7>
            break;
  800e8b:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  800e8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e90:	74 08                	je     800e9a <strtol+0x144>
        *endptr = (char *) s;
  800e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  800e9a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e9e:	74 07                	je     800ea7 <strtol+0x151>
  800ea0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ea3:	f7 d8                	neg    %eax
  800ea5:	eb 03                	jmp    800eaa <strtol+0x154>
  800ea7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800eaa:	89 ec                	mov    %ebp,%esp
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 28             	sub    $0x28,%esp
  800eb4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eba:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800ebd:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800ec7:	88 55 f7             	mov    %dl,-0x9(%ebp)
  800eca:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800ed0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800ed3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ed7:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800eda:	89 d7                	mov    %edx,%edi
  800edc:	f3 aa                	rep stos %al,%es:(%edi)
  800ede:	89 fa                	mov    %edi,%edx
  800ee0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800ee3:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800ee6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800ee9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eec:	89 ec                	mov    %ebp,%esp
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 30             	sub    $0x30,%esp
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f05:	8b 45 10             	mov    0x10(%ebp),%eax
  800f08:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f11:	73 42                	jae    800f55 <memmove+0x65>
  800f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f22:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800f25:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f28:	c1 e8 02             	shr    $0x2,%eax
  800f2b:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800f2d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f33:	89 d7                	mov    %edx,%edi
  800f35:	89 c6                	mov    %eax,%esi
  800f37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f39:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800f3c:	83 e1 03             	and    $0x3,%ecx
  800f3f:	74 02                	je     800f43 <memmove+0x53>
  800f41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	89 fa                	mov    %edi,%edx
  800f47:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800f4a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800f4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  800f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  800f53:	eb 36                	jmp    800f8b <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800f55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f58:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5e:	01 c2                	add    %eax,%edx
  800f60:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f63:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f69:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  800f6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	89 d6                	mov    %edx,%esi
  800f75:	89 c7                	mov    %eax,%edi
  800f77:	fd                   	std    
  800f78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f7a:	fc                   	cld    
  800f7b:	89 f8                	mov    %edi,%eax
  800f7d:	89 f2                	mov    %esi,%edx
  800f7f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800f82:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800f85:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  800f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800f8b:	83 c4 30             	add    $0x30,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	83 ec 20             	sub    $0x20,%esp
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fa7:	8b 45 10             	mov    0x10(%ebp),%eax
  800faa:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fb0:	c1 e8 02             	shr    $0x2,%eax
  800fb3:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800fb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbb:	89 d7                	mov    %edx,%edi
  800fbd:	89 c6                	mov    %eax,%esi
  800fbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800fc4:	83 e1 03             	and    $0x3,%ecx
  800fc7:	74 02                	je     800fcb <memcpy+0x38>
  800fc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800fcb:	89 f0                	mov    %esi,%eax
  800fcd:	89 fa                	mov    %edi,%edx
  800fcf:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800fd2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800fdb:	83 c4 20             	add    $0x20,%esp
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  800feb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800fee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff1:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  800ff4:	eb 2e                	jmp    801024 <memcmp+0x42>
        if (*s1 != *s2) {
  800ff6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ff9:	0f b6 10             	movzbl (%eax),%edx
  800ffc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fff:	0f b6 00             	movzbl (%eax),%eax
  801002:	38 c2                	cmp    %al,%dl
  801004:	74 18                	je     80101e <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  801006:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801009:	0f b6 00             	movzbl (%eax),%eax
  80100c:	0f b6 d0             	movzbl %al,%edx
  80100f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801012:	0f b6 00             	movzbl (%eax),%eax
  801015:	0f b6 c8             	movzbl %al,%ecx
  801018:	89 d0                	mov    %edx,%eax
  80101a:	29 c8                	sub    %ecx,%eax
  80101c:	eb 18                	jmp    801036 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  80101e:	ff 45 fc             	incl   -0x4(%ebp)
  801021:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  801024:	8b 45 10             	mov    0x10(%ebp),%eax
  801027:	8d 50 ff             	lea    -0x1(%eax),%edx
  80102a:	89 55 10             	mov    %edx,0x10(%ebp)
  80102d:	85 c0                	test   %eax,%eax
  80102f:	75 c5                	jne    800ff6 <memcmp+0x14>
    }
    return 0;
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801036:	89 ec                	mov    %ebp,%esp
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 e4 f0             	and    $0xfffffff0,%esp
  801040:	83 ec 10             	sub    $0x10,%esp
    cprintf("Hello world!!.\n");
  801043:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  80104a:	e8 d1 f0 ff ff       	call   800120 <cprintf>
    cprintf("I am process %d.\n", getpid());
  80104f:	e8 4b f3 ff ff       	call   80039f <getpid>
  801054:	89 44 24 04          	mov    %eax,0x4(%esp)
  801058:	c7 04 24 70 13 80 00 	movl   $0x801370,(%esp)
  80105f:	e8 bc f0 ff ff       	call   800120 <cprintf>
    cprintf("hello pass.\n");
  801064:	c7 04 24 82 13 80 00 	movl   $0x801382,(%esp)
  80106b:	e8 b0 f0 ff ff       	call   800120 <cprintf>
    return 0;
  801070:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801075:	89 ec                	mov    %ebp,%esp
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    
