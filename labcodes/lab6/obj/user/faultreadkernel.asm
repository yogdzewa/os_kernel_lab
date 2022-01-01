
obj/__user_faultreadkernel.out:     file format elf32-i386


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
  800028:	e8 99 03 00 00       	call   8003c6 <umain>
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
  800049:	c7 04 24 60 10 80 00 	movl   $0x801060,(%esp)
  800050:	e8 cb 00 00 00       	call   800120 <cprintf>
    vcprintf(fmt, ap);
  800055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	8b 45 10             	mov    0x10(%ebp),%eax
  80005f:	89 04 24             	mov    %eax,(%esp)
  800062:	e8 84 00 00 00       	call   8000eb <vcprintf>
    cprintf("\n");
  800067:	c7 04 24 7a 10 80 00 	movl   $0x80107a,(%esp)
  80006e:	e8 ad 00 00 00       	call   800120 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800073:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80007a:	e8 76 02 00 00       	call   8002f5 <exit>

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
  800099:	c7 04 24 7c 10 80 00 	movl   $0x80107c,(%esp)
  8000a0:	e8 7b 00 00 00       	call   800120 <cprintf>
    vcprintf(fmt, ap);
  8000a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8000af:	89 04 24             	mov    %eax,(%esp)
  8000b2:	e8 34 00 00 00       	call   8000eb <vcprintf>
    cprintf("\n");
  8000b7:	c7 04 24 7a 10 80 00 	movl   $0x80107a,(%esp)
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
  800114:	e8 b6 04 00 00       	call   8005cf <vprintfmt>
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

008002f5 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	e8 e8 fe ff ff       	call   8001ee <sys_exit>
    cprintf("BUG: exit failed.\n");
  800306:	c7 04 24 98 10 80 00 	movl   $0x801098,(%esp)
  80030d:	e8 0e fe ff ff       	call   800120 <cprintf>
    while (1);
  800312:	eb fe                	jmp    800312 <exit+0x1d>

00800314 <fork>:
}

int
fork(void) {
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  80031a:	e8 ec fe ff ff       	call   80020b <sys_fork>
}
  80031f:	89 ec                	mov    %ebp,%esp
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <wait>:

int
wait(void) {
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800329:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800330:	00 
  800331:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800338:	e8 e4 fe ff ff       	call   800221 <sys_wait>
}
  80033d:	89 ec                	mov    %ebp,%esp
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <waitpid>:

int
waitpid(int pid, int *store) {
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800347:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	e8 c8 fe ff ff       	call   800221 <sys_wait>
}
  800359:	89 ec                	mov    %ebp,%esp
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <yield>:

void
yield(void) {
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800363:	e8 dd fe ff ff       	call   800245 <sys_yield>
}
  800368:	90                   	nop
  800369:	89 ec                	mov    %ebp,%esp
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <kill>:

int
kill(int pid) {
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	89 04 24             	mov    %eax,(%esp)
  800379:	e8 dd fe ff ff       	call   80025b <sys_kill>
}
  80037e:	89 ec                	mov    %ebp,%esp
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <getpid>:

int
getpid(void) {
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800388:	e8 eb fe ff ff       	call   800278 <sys_getpid>
}
  80038d:	89 ec                	mov    %ebp,%esp
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800397:	e8 0f ff ff ff       	call   8002ab <sys_pgdir>
}
  80039c:	90                   	nop
  80039d:	89 ec                	mov    %ebp,%esp
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <gettime_msec>:

unsigned int
gettime_msec(void) {
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  8003a7:	e8 15 ff ff ff       	call   8002c1 <sys_gettime>
}
  8003ac:	89 ec                	mov    %ebp,%esp
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	89 04 24             	mov    %eax,(%esp)
  8003bc:	e8 16 ff ff ff       	call   8002d7 <sys_lab6_set_priority>
}
  8003c1:	90                   	nop
  8003c2:	89 ec                	mov    %ebp,%esp
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  8003cc:	e8 37 0c 00 00       	call   801008 <main>
  8003d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  8003d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 16 ff ff ff       	call   8002f5 <exit>

008003df <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  8003ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  8003f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8003f6:	2b 45 0c             	sub    0xc(%ebp),%eax
  8003f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8003fc:	88 c1                	mov    %al,%cl
  8003fe:	d3 ea                	shr    %cl,%edx
  800400:	89 d0                	mov    %edx,%eax
}
  800402:	89 ec                	mov    %ebp,%esp
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 58             	sub    $0x58,%esp
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
  80040f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800418:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80041e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800421:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800424:	8b 45 18             	mov    0x18(%ebp),%eax
  800427:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80042d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800439:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80043c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800440:	74 1c                	je     80045e <printnum+0x58>
  800442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800445:	ba 00 00 00 00       	mov    $0x0,%edx
  80044a:	f7 75 e4             	divl   -0x1c(%ebp)
  80044d:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800453:	ba 00 00 00 00       	mov    $0x0,%edx
  800458:	f7 75 e4             	divl   -0x1c(%ebp)
  80045b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80045e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800461:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800464:	f7 75 e4             	divl   -0x1c(%ebp)
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80046d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800470:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800473:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800476:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800479:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047c:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80047f:	8b 45 18             	mov    0x18(%ebp),%eax
  800482:	ba 00 00 00 00       	mov    $0x0,%edx
  800487:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80048a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  80048d:	19 d1                	sbb    %edx,%ecx
  80048f:	72 4c                	jb     8004dd <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  800491:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800494:	8d 50 ff             	lea    -0x1(%eax),%edx
  800497:	8b 45 20             	mov    0x20(%ebp),%eax
  80049a:	89 44 24 18          	mov    %eax,0x18(%esp)
  80049e:	89 54 24 14          	mov    %edx,0x14(%esp)
  8004a2:	8b 45 18             	mov    0x18(%ebp),%eax
  8004a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8004ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8004af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 3d ff ff ff       	call   800406 <printnum>
  8004c9:	eb 1b                	jmp    8004e6 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  8004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d2:	8b 45 20             	mov    0x20(%ebp),%eax
  8004d5:	89 04 24             	mov    %eax,(%esp)
  8004d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004db:	ff d0                	call   *%eax
        while (-- width > 0)
  8004dd:	ff 4d 1c             	decl   0x1c(%ebp)
  8004e0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8004e4:	7f e5                	jg     8004cb <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8004e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004e9:	05 c4 11 80 00       	add    $0x8011c4,%eax
  8004ee:	0f b6 00             	movzbl (%eax),%eax
  8004f1:	0f be c0             	movsbl %al,%eax
  8004f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	ff d0                	call   *%eax
}
  800503:	90                   	nop
  800504:	89 ec                	mov    %ebp,%esp
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80050b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80050f:	7e 14                	jle    800525 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800511:	8b 45 08             	mov    0x8(%ebp),%eax
  800514:	8b 00                	mov    (%eax),%eax
  800516:	8d 48 08             	lea    0x8(%eax),%ecx
  800519:	8b 55 08             	mov    0x8(%ebp),%edx
  80051c:	89 0a                	mov    %ecx,(%edx)
  80051e:	8b 50 04             	mov    0x4(%eax),%edx
  800521:	8b 00                	mov    (%eax),%eax
  800523:	eb 30                	jmp    800555 <getuint+0x4d>
    }
    else if (lflag) {
  800525:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800529:	74 16                	je     800541 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	8d 48 04             	lea    0x4(%eax),%ecx
  800533:	8b 55 08             	mov    0x8(%ebp),%edx
  800536:	89 0a                	mov    %ecx,(%edx)
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	ba 00 00 00 00       	mov    $0x0,%edx
  80053f:	eb 14                	jmp    800555 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800541:	8b 45 08             	mov    0x8(%ebp),%eax
  800544:	8b 00                	mov    (%eax),%eax
  800546:	8d 48 04             	lea    0x4(%eax),%ecx
  800549:	8b 55 08             	mov    0x8(%ebp),%edx
  80054c:	89 0a                	mov    %ecx,(%edx)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800555:	5d                   	pop    %ebp
  800556:	c3                   	ret    

00800557 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800557:	55                   	push   %ebp
  800558:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80055a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80055e:	7e 14                	jle    800574 <getint+0x1d>
        return va_arg(*ap, long long);
  800560:	8b 45 08             	mov    0x8(%ebp),%eax
  800563:	8b 00                	mov    (%eax),%eax
  800565:	8d 48 08             	lea    0x8(%eax),%ecx
  800568:	8b 55 08             	mov    0x8(%ebp),%edx
  80056b:	89 0a                	mov    %ecx,(%edx)
  80056d:	8b 50 04             	mov    0x4(%eax),%edx
  800570:	8b 00                	mov    (%eax),%eax
  800572:	eb 28                	jmp    80059c <getint+0x45>
    }
    else if (lflag) {
  800574:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800578:	74 12                	je     80058c <getint+0x35>
        return va_arg(*ap, long);
  80057a:	8b 45 08             	mov    0x8(%ebp),%eax
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	8d 48 04             	lea    0x4(%eax),%ecx
  800582:	8b 55 08             	mov    0x8(%ebp),%edx
  800585:	89 0a                	mov    %ecx,(%edx)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	99                   	cltd   
  80058a:	eb 10                	jmp    80059c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	8d 48 04             	lea    0x4(%eax),%ecx
  800594:	8b 55 08             	mov    0x8(%ebp),%edx
  800597:	89 0a                	mov    %ecx,(%edx)
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	99                   	cltd   
    }
}
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    

0080059e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8005a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  8005aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	e8 05 00 00 00       	call   8005cf <vprintfmt>
    va_end(ap);
}
  8005ca:	90                   	nop
  8005cb:	89 ec                	mov    %ebp,%esp
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	56                   	push   %esi
  8005d3:	53                   	push   %ebx
  8005d4:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8005d7:	eb 17                	jmp    8005f0 <vprintfmt+0x21>
            if (ch == '\0') {
  8005d9:	85 db                	test   %ebx,%ebx
  8005db:	0f 84 bf 03 00 00    	je     8009a0 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  8005e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e8:	89 1c 24             	mov    %ebx,(%esp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8005f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f3:	8d 50 01             	lea    0x1(%eax),%edx
  8005f6:	89 55 10             	mov    %edx,0x10(%ebp)
  8005f9:	0f b6 00             	movzbl (%eax),%eax
  8005fc:	0f b6 d8             	movzbl %al,%ebx
  8005ff:	83 fb 25             	cmp    $0x25,%ebx
  800602:	75 d5                	jne    8005d9 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800604:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800608:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80060f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800612:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800615:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80061c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800622:	8b 45 10             	mov    0x10(%ebp),%eax
  800625:	8d 50 01             	lea    0x1(%eax),%edx
  800628:	89 55 10             	mov    %edx,0x10(%ebp)
  80062b:	0f b6 00             	movzbl (%eax),%eax
  80062e:	0f b6 d8             	movzbl %al,%ebx
  800631:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800634:	83 f8 55             	cmp    $0x55,%eax
  800637:	0f 87 37 03 00 00    	ja     800974 <vprintfmt+0x3a5>
  80063d:	8b 04 85 e8 11 80 00 	mov    0x8011e8(,%eax,4),%eax
  800644:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800646:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  80064a:	eb d6                	jmp    800622 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  80064c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800650:	eb d0                	jmp    800622 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800652:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800659:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065c:	89 d0                	mov    %edx,%eax
  80065e:	c1 e0 02             	shl    $0x2,%eax
  800661:	01 d0                	add    %edx,%eax
  800663:	01 c0                	add    %eax,%eax
  800665:	01 d8                	add    %ebx,%eax
  800667:	83 e8 30             	sub    $0x30,%eax
  80066a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  80066d:	8b 45 10             	mov    0x10(%ebp),%eax
  800670:	0f b6 00             	movzbl (%eax),%eax
  800673:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800676:	83 fb 2f             	cmp    $0x2f,%ebx
  800679:	7e 38                	jle    8006b3 <vprintfmt+0xe4>
  80067b:	83 fb 39             	cmp    $0x39,%ebx
  80067e:	7f 33                	jg     8006b3 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  800680:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  800683:	eb d4                	jmp    800659 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 50 04             	lea    0x4(%eax),%edx
  80068b:	89 55 14             	mov    %edx,0x14(%ebp)
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800693:	eb 1f                	jmp    8006b4 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  800695:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800699:	79 87                	jns    800622 <vprintfmt+0x53>
                width = 0;
  80069b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  8006a2:	e9 7b ff ff ff       	jmp    800622 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  8006a7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  8006ae:	e9 6f ff ff ff       	jmp    800622 <vprintfmt+0x53>
            goto process_precision;
  8006b3:	90                   	nop

        process_precision:
            if (width < 0)
  8006b4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006b8:	0f 89 64 ff ff ff    	jns    800622 <vprintfmt+0x53>
                width = precision, precision = -1;
  8006be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8006c4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  8006cb:	e9 52 ff ff ff       	jmp    800622 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  8006d0:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  8006d3:	e9 4a ff ff ff       	jmp    800622 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	ff d0                	call   *%eax
            break;
  8006f2:	e9 a4 02 00 00       	jmp    80099b <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800702:	85 db                	test   %ebx,%ebx
  800704:	79 02                	jns    800708 <vprintfmt+0x139>
                err = -err;
  800706:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800708:	83 fb 18             	cmp    $0x18,%ebx
  80070b:	7f 0b                	jg     800718 <vprintfmt+0x149>
  80070d:	8b 34 9d 60 11 80 00 	mov    0x801160(,%ebx,4),%esi
  800714:	85 f6                	test   %esi,%esi
  800716:	75 23                	jne    80073b <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  800718:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80071c:	c7 44 24 08 d5 11 80 	movl   $0x8011d5,0x8(%esp)
  800723:	00 
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	89 04 24             	mov    %eax,(%esp)
  800731:	e8 68 fe ff ff       	call   80059e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800736:	e9 60 02 00 00       	jmp    80099b <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  80073b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80073f:	c7 44 24 08 de 11 80 	movl   $0x8011de,0x8(%esp)
  800746:	00 
  800747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	89 04 24             	mov    %eax,(%esp)
  800754:	e8 45 fe ff ff       	call   80059e <printfmt>
            break;
  800759:	e9 3d 02 00 00       	jmp    80099b <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8d 50 04             	lea    0x4(%eax),%edx
  800764:	89 55 14             	mov    %edx,0x14(%ebp)
  800767:	8b 30                	mov    (%eax),%esi
  800769:	85 f6                	test   %esi,%esi
  80076b:	75 05                	jne    800772 <vprintfmt+0x1a3>
                p = "(null)";
  80076d:	be e1 11 80 00       	mov    $0x8011e1,%esi
            }
            if (width > 0 && padc != '-') {
  800772:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800776:	7e 76                	jle    8007ee <vprintfmt+0x21f>
  800778:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80077c:	74 70                	je     8007ee <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80077e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800781:	89 44 24 04          	mov    %eax,0x4(%esp)
  800785:	89 34 24             	mov    %esi,(%esp)
  800788:	e8 ee 03 00 00       	call   800b7b <strnlen>
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800792:	29 d0                	sub    %edx,%eax
  800794:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800797:	eb 16                	jmp    8007af <vprintfmt+0x1e0>
                    putch(padc, putdat);
  800799:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  8007ac:	ff 4d e8             	decl   -0x18(%ebp)
  8007af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8007b3:	7f e4                	jg     800799 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8007b5:	eb 37                	jmp    8007ee <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  8007b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007bb:	74 1f                	je     8007dc <vprintfmt+0x20d>
  8007bd:	83 fb 1f             	cmp    $0x1f,%ebx
  8007c0:	7e 05                	jle    8007c7 <vprintfmt+0x1f8>
  8007c2:	83 fb 7e             	cmp    $0x7e,%ebx
  8007c5:	7e 15                	jle    8007dc <vprintfmt+0x20d>
                    putch('?', putdat);
  8007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ce:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	ff d0                	call   *%eax
  8007da:	eb 0f                	jmp    8007eb <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  8007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e3:	89 1c 24             	mov    %ebx,(%esp)
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8007eb:	ff 4d e8             	decl   -0x18(%ebp)
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	8d 70 01             	lea    0x1(%eax),%esi
  8007f3:	0f b6 00             	movzbl (%eax),%eax
  8007f6:	0f be d8             	movsbl %al,%ebx
  8007f9:	85 db                	test   %ebx,%ebx
  8007fb:	74 27                	je     800824 <vprintfmt+0x255>
  8007fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800801:	78 b4                	js     8007b7 <vprintfmt+0x1e8>
  800803:	ff 4d e4             	decl   -0x1c(%ebp)
  800806:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080a:	79 ab                	jns    8007b7 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  80080c:	eb 16                	jmp    800824 <vprintfmt+0x255>
                putch(' ', putdat);
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  800821:	ff 4d e8             	decl   -0x18(%ebp)
  800824:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800828:	7f e4                	jg     80080e <vprintfmt+0x23f>
            }
            break;
  80082a:	e9 6c 01 00 00       	jmp    80099b <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  80082f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800832:	89 44 24 04          	mov    %eax,0x4(%esp)
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
  800839:	89 04 24             	mov    %eax,(%esp)
  80083c:	e8 16 fd ff ff       	call   800557 <getint>
  800841:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800844:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084d:	85 d2                	test   %edx,%edx
  80084f:	79 26                	jns    800877 <vprintfmt+0x2a8>
                putch('-', putdat);
  800851:	8b 45 0c             	mov    0xc(%ebp),%eax
  800854:	89 44 24 04          	mov    %eax,0x4(%esp)
  800858:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	ff d0                	call   *%eax
                num = -(long long)num;
  800864:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800867:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80086a:	f7 d8                	neg    %eax
  80086c:	83 d2 00             	adc    $0x0,%edx
  80086f:	f7 da                	neg    %edx
  800871:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800874:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800877:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  80087e:	e9 a8 00 00 00       	jmp    80092b <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800883:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800886:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
  80088d:	89 04 24             	mov    %eax,(%esp)
  800890:	e8 73 fc ff ff       	call   800508 <getuint>
  800895:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800898:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  80089b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  8008a2:	e9 84 00 00 00       	jmp    80092b <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  8008a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b1:	89 04 24             	mov    %eax,(%esp)
  8008b4:	e8 4f fc ff ff       	call   800508 <getuint>
  8008b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  8008bf:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  8008c6:	eb 63                	jmp    80092b <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	ff d0                	call   *%eax
            putch('x', putdat);
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8d 50 04             	lea    0x4(%eax),%edx
  8008f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f7:	8b 00                	mov    (%eax),%eax
  8008f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800903:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  80090a:	eb 1f                	jmp    80092b <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  80090c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80090f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800913:	8d 45 14             	lea    0x14(%ebp),%eax
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	e8 ea fb ff ff       	call   800508 <getuint>
  80091e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800921:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800924:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  80092b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80092f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800932:	89 54 24 18          	mov    %edx,0x18(%esp)
  800936:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800939:	89 54 24 14          	mov    %edx,0x14(%esp)
  80093d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800944:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800947:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	89 44 24 04          	mov    %eax,0x4(%esp)
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	89 04 24             	mov    %eax,(%esp)
  80095c:	e8 a5 fa ff ff       	call   800406 <printnum>
            break;
  800961:	eb 38                	jmp    80099b <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800963:	8b 45 0c             	mov    0xc(%ebp),%eax
  800966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096a:	89 1c 24             	mov    %ebx,(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	ff d0                	call   *%eax
            break;
  800972:	eb 27                	jmp    80099b <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  800987:	ff 4d 10             	decl   0x10(%ebp)
  80098a:	eb 03                	jmp    80098f <vprintfmt+0x3c0>
  80098c:	ff 4d 10             	decl   0x10(%ebp)
  80098f:	8b 45 10             	mov    0x10(%ebp),%eax
  800992:	48                   	dec    %eax
  800993:	0f b6 00             	movzbl (%eax),%eax
  800996:	3c 25                	cmp    $0x25,%al
  800998:	75 f2                	jne    80098c <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  80099a:	90                   	nop
    while (1) {
  80099b:	e9 37 fc ff ff       	jmp    8005d7 <vprintfmt+0x8>
                return;
  8009a0:	90                   	nop
        }
    }
}
  8009a1:	83 c4 40             	add    $0x40,%esp
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	8b 40 08             	mov    0x8(%eax),%eax
  8009b1:	8d 50 01             	lea    0x1(%eax),%edx
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	8b 10                	mov    (%eax),%edx
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	8b 40 04             	mov    0x4(%eax),%eax
  8009c5:	39 c2                	cmp    %eax,%edx
  8009c7:	73 12                	jae    8009db <sprintputch+0x33>
        *b->buf ++ = ch;
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	8b 00                	mov    (%eax),%eax
  8009ce:	8d 48 01             	lea    0x1(%eax),%ecx
  8009d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d4:	89 0a                	mov    %ecx,(%edx)
  8009d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d9:	88 10                	mov    %dl,(%eax)
    }
}
  8009db:	90                   	nop
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  8009e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  8009ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	89 04 24             	mov    %eax,(%esp)
  800a05:	e8 0a 00 00 00       	call   800a14 <vsnprintf>
  800a0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a10:	89 ec                	mov    %ebp,%esp
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	01 d0                	add    %edx,%eax
  800a2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800a35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a39:	74 0a                	je     800a45 <vsnprintf+0x31>
  800a3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a41:	39 c2                	cmp    %eax,%edx
  800a43:	76 07                	jbe    800a4c <vsnprintf+0x38>
        return -E_INVAL;
  800a45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a4a:	eb 2a                	jmp    800a76 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a53:	8b 45 10             	mov    0x10(%ebp),%eax
  800a56:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a61:	c7 04 24 a8 09 80 00 	movl   $0x8009a8,(%esp)
  800a68:	e8 62 fb ff ff       	call   8005cf <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a70:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a76:	89 ec                	mov    %ebp,%esp
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800a83:	a1 00 20 80 00       	mov    0x802000,%eax
  800a88:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800a8e:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800a94:	6b f0 05             	imul   $0x5,%eax,%esi
  800a97:	01 fe                	add    %edi,%esi
  800a99:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  800a9e:	f7 e7                	mul    %edi
  800aa0:	01 d6                	add    %edx,%esi
  800aa2:	89 f2                	mov    %esi,%edx
  800aa4:	83 c0 0b             	add    $0xb,%eax
  800aa7:	83 d2 00             	adc    $0x0,%edx
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	83 e7 ff             	and    $0xffffffff,%edi
  800aaf:	89 f9                	mov    %edi,%ecx
  800ab1:	0f b7 da             	movzwl %dx,%ebx
  800ab4:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800aba:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800ac0:	a1 00 20 80 00       	mov    0x802000,%eax
  800ac5:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800acb:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800acf:	c1 ea 0c             	shr    $0xc,%edx
  800ad2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ad5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800ad8:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800adf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ae2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ae5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800af1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800af5:	74 1c                	je     800b13 <rand+0x99>
  800af7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	f7 75 dc             	divl   -0x24(%ebp)
  800b02:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800b05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	f7 75 dc             	divl   -0x24(%ebp)
  800b10:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b13:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b16:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b19:	f7 75 dc             	divl   -0x24(%ebp)
  800b1c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b22:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b25:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800b28:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800b31:	83 c4 24             	add    $0x24,%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
    next = seed;
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	a3 00 20 80 00       	mov    %eax,0x802000
  800b49:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800b4f:	90                   	nop
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800b58:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  800b5f:	eb 03                	jmp    800b64 <strlen+0x12>
        cnt ++;
  800b61:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	8d 50 01             	lea    0x1(%eax),%edx
  800b6a:	89 55 08             	mov    %edx,0x8(%ebp)
  800b6d:	0f b6 00             	movzbl (%eax),%eax
  800b70:	84 c0                	test   %al,%al
  800b72:	75 ed                	jne    800b61 <strlen+0xf>
    }
    return cnt;
  800b74:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b77:	89 ec                	mov    %ebp,%esp
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800b81:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800b88:	eb 03                	jmp    800b8d <strnlen+0x12>
        cnt ++;
  800b8a:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800b8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b90:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800b93:	73 10                	jae    800ba5 <strnlen+0x2a>
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	8d 50 01             	lea    0x1(%eax),%edx
  800b9b:	89 55 08             	mov    %edx,0x8(%ebp)
  800b9e:	0f b6 00             	movzbl (%eax),%eax
  800ba1:	84 c0                	test   %al,%al
  800ba3:	75 e5                	jne    800b8a <strnlen+0xf>
    }
    return cnt;
  800ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ba8:	89 ec                	mov    %ebp,%esp
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	83 ec 20             	sub    $0x20,%esp
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800bc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 c2                	mov    %eax,%edx
  800bca:	89 ce                	mov    %ecx,%esi
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	ac                   	lods   %ds:(%esi),%al
  800bcf:	aa                   	stos   %al,%es:(%edi)
  800bd0:	84 c0                	test   %al,%al
  800bd2:	75 fa                	jne    800bce <strcpy+0x22>
  800bd4:	89 fa                	mov    %edi,%edx
  800bd6:	89 f1                	mov    %esi,%ecx
  800bd8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800bdb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800bde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800be4:	83 c4 20             	add    $0x20,%esp
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800bf7:	eb 1e                	jmp    800c17 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  800bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfc:	0f b6 10             	movzbl (%eax),%edx
  800bff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c02:	88 10                	mov    %dl,(%eax)
  800c04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c07:	0f b6 00             	movzbl (%eax),%eax
  800c0a:	84 c0                	test   %al,%al
  800c0c:	74 03                	je     800c11 <strncpy+0x26>
            src ++;
  800c0e:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  800c11:	ff 45 fc             	incl   -0x4(%ebp)
  800c14:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  800c17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c1b:	75 dc                	jne    800bf9 <strncpy+0xe>
    }
    return dst;
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c20:	89 ec                	mov    %ebp,%esp
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	83 ec 20             	sub    $0x20,%esp
  800c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  800c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3e:	89 d1                	mov    %edx,%ecx
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	89 ce                	mov    %ecx,%esi
  800c44:	89 d7                	mov    %edx,%edi
  800c46:	ac                   	lods   %ds:(%esi),%al
  800c47:	ae                   	scas   %es:(%edi),%al
  800c48:	75 08                	jne    800c52 <strcmp+0x2e>
  800c4a:	84 c0                	test   %al,%al
  800c4c:	75 f8                	jne    800c46 <strcmp+0x22>
  800c4e:	31 c0                	xor    %eax,%eax
  800c50:	eb 04                	jmp    800c56 <strcmp+0x32>
  800c52:	19 c0                	sbb    %eax,%eax
  800c54:	0c 01                	or     $0x1,%al
  800c56:	89 fa                	mov    %edi,%edx
  800c58:	89 f1                	mov    %esi,%ecx
  800c5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c5d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800c60:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  800c63:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  800c66:	83 c4 20             	add    $0x20,%esp
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800c70:	eb 09                	jmp    800c7b <strncmp+0xe>
        n --, s1 ++, s2 ++;
  800c72:	ff 4d 10             	decl   0x10(%ebp)
  800c75:	ff 45 08             	incl   0x8(%ebp)
  800c78:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800c7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c7f:	74 1a                	je     800c9b <strncmp+0x2e>
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	0f b6 00             	movzbl (%eax),%eax
  800c87:	84 c0                	test   %al,%al
  800c89:	74 10                	je     800c9b <strncmp+0x2e>
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	0f b6 10             	movzbl (%eax),%edx
  800c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c94:	0f b6 00             	movzbl (%eax),%eax
  800c97:	38 c2                	cmp    %al,%dl
  800c99:	74 d7                	je     800c72 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800c9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c9f:	74 18                	je     800cb9 <strncmp+0x4c>
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	0f b6 00             	movzbl (%eax),%eax
  800ca7:	0f b6 d0             	movzbl %al,%edx
  800caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cad:	0f b6 00             	movzbl (%eax),%eax
  800cb0:	0f b6 c8             	movzbl %al,%ecx
  800cb3:	89 d0                	mov    %edx,%eax
  800cb5:	29 c8                	sub    %ecx,%eax
  800cb7:	eb 05                	jmp    800cbe <strncmp+0x51>
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 04             	sub    $0x4,%esp
  800cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc9:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800ccc:	eb 13                	jmp    800ce1 <strchr+0x21>
        if (*s == c) {
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	0f b6 00             	movzbl (%eax),%eax
  800cd4:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800cd7:	75 05                	jne    800cde <strchr+0x1e>
            return (char *)s;
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	eb 12                	jmp    800cf0 <strchr+0x30>
        }
        s ++;
  800cde:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce4:	0f b6 00             	movzbl (%eax),%eax
  800ce7:	84 c0                	test   %al,%al
  800ce9:	75 e3                	jne    800cce <strchr+0xe>
    }
    return NULL;
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf0:	89 ec                	mov    %ebp,%esp
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 04             	sub    $0x4,%esp
  800cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfd:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800d00:	eb 0e                	jmp    800d10 <strfind+0x1c>
        if (*s == c) {
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	0f b6 00             	movzbl (%eax),%eax
  800d08:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800d0b:	74 0f                	je     800d1c <strfind+0x28>
            break;
        }
        s ++;
  800d0d:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	0f b6 00             	movzbl (%eax),%eax
  800d16:	84 c0                	test   %al,%al
  800d18:	75 e8                	jne    800d02 <strfind+0xe>
  800d1a:	eb 01                	jmp    800d1d <strfind+0x29>
            break;
  800d1c:	90                   	nop
    }
    return (char *)s;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d20:	89 ec                	mov    %ebp,%esp
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800d2a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800d31:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800d38:	eb 03                	jmp    800d3d <strtol+0x19>
        s ++;
  800d3a:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	0f b6 00             	movzbl (%eax),%eax
  800d43:	3c 20                	cmp    $0x20,%al
  800d45:	74 f3                	je     800d3a <strtol+0x16>
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	0f b6 00             	movzbl (%eax),%eax
  800d4d:	3c 09                	cmp    $0x9,%al
  800d4f:	74 e9                	je     800d3a <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	0f b6 00             	movzbl (%eax),%eax
  800d57:	3c 2b                	cmp    $0x2b,%al
  800d59:	75 05                	jne    800d60 <strtol+0x3c>
        s ++;
  800d5b:	ff 45 08             	incl   0x8(%ebp)
  800d5e:	eb 14                	jmp    800d74 <strtol+0x50>
    }
    else if (*s == '-') {
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	3c 2d                	cmp    $0x2d,%al
  800d68:	75 0a                	jne    800d74 <strtol+0x50>
        s ++, neg = 1;
  800d6a:	ff 45 08             	incl   0x8(%ebp)
  800d6d:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  800d74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d78:	74 06                	je     800d80 <strtol+0x5c>
  800d7a:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d7e:	75 22                	jne    800da2 <strtol+0x7e>
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	0f b6 00             	movzbl (%eax),%eax
  800d86:	3c 30                	cmp    $0x30,%al
  800d88:	75 18                	jne    800da2 <strtol+0x7e>
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	40                   	inc    %eax
  800d8e:	0f b6 00             	movzbl (%eax),%eax
  800d91:	3c 78                	cmp    $0x78,%al
  800d93:	75 0d                	jne    800da2 <strtol+0x7e>
        s += 2, base = 16;
  800d95:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d99:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800da0:	eb 29                	jmp    800dcb <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  800da2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da6:	75 16                	jne    800dbe <strtol+0x9a>
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	0f b6 00             	movzbl (%eax),%eax
  800dae:	3c 30                	cmp    $0x30,%al
  800db0:	75 0c                	jne    800dbe <strtol+0x9a>
        s ++, base = 8;
  800db2:	ff 45 08             	incl   0x8(%ebp)
  800db5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dbc:	eb 0d                	jmp    800dcb <strtol+0xa7>
    }
    else if (base == 0) {
  800dbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc2:	75 07                	jne    800dcb <strtol+0xa7>
        base = 10;
  800dc4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	0f b6 00             	movzbl (%eax),%eax
  800dd1:	3c 2f                	cmp    $0x2f,%al
  800dd3:	7e 1b                	jle    800df0 <strtol+0xcc>
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	0f b6 00             	movzbl (%eax),%eax
  800ddb:	3c 39                	cmp    $0x39,%al
  800ddd:	7f 11                	jg     800df0 <strtol+0xcc>
            dig = *s - '0';
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 00             	movzbl (%eax),%eax
  800de5:	0f be c0             	movsbl %al,%eax
  800de8:	83 e8 30             	sub    $0x30,%eax
  800deb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dee:	eb 48                	jmp    800e38 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	3c 60                	cmp    $0x60,%al
  800df8:	7e 1b                	jle    800e15 <strtol+0xf1>
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	3c 7a                	cmp    $0x7a,%al
  800e02:	7f 11                	jg     800e15 <strtol+0xf1>
            dig = *s - 'a' + 10;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	0f b6 00             	movzbl (%eax),%eax
  800e0a:	0f be c0             	movsbl %al,%eax
  800e0d:	83 e8 57             	sub    $0x57,%eax
  800e10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e13:	eb 23                	jmp    800e38 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	3c 40                	cmp    $0x40,%al
  800e1d:	7e 3b                	jle    800e5a <strtol+0x136>
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	0f b6 00             	movzbl (%eax),%eax
  800e25:	3c 5a                	cmp    $0x5a,%al
  800e27:	7f 31                	jg     800e5a <strtol+0x136>
            dig = *s - 'A' + 10;
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	0f b6 00             	movzbl (%eax),%eax
  800e2f:	0f be c0             	movsbl %al,%eax
  800e32:	83 e8 37             	sub    $0x37,%eax
  800e35:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e3e:	7d 19                	jge    800e59 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  800e40:	ff 45 08             	incl   0x8(%ebp)
  800e43:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e46:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e4a:	89 c2                	mov    %eax,%edx
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4f:	01 d0                	add    %edx,%eax
  800e51:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  800e54:	e9 72 ff ff ff       	jmp    800dcb <strtol+0xa7>
            break;
  800e59:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  800e5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e5e:	74 08                	je     800e68 <strtol+0x144>
        *endptr = (char *) s;
  800e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  800e68:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e6c:	74 07                	je     800e75 <strtol+0x151>
  800e6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e71:	f7 d8                	neg    %eax
  800e73:	eb 03                	jmp    800e78 <strtol+0x154>
  800e75:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e78:	89 ec                	mov    %ebp,%esp
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 28             	sub    $0x28,%esp
  800e82:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e88:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800e8b:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800e95:	88 55 f7             	mov    %dl,-0x9(%ebp)
  800e98:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800e9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800ea1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ea5:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800ea8:	89 d7                	mov    %edx,%edi
  800eaa:	f3 aa                	rep stos %al,%es:(%edi)
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800eb1:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800eb4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800eb7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eba:	89 ec                	mov    %ebp,%esp
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 30             	sub    $0x30,%esp
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ed3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed6:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800edf:	73 42                	jae    800f23 <memmove+0x65>
  800ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ee7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ef0:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800ef3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ef6:	c1 e8 02             	shr    $0x2,%eax
  800ef9:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800efb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800efe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f01:	89 d7                	mov    %edx,%edi
  800f03:	89 c6                	mov    %eax,%esi
  800f05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f07:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800f0a:	83 e1 03             	and    $0x3,%ecx
  800f0d:	74 02                	je     800f11 <memmove+0x53>
  800f0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f11:	89 f0                	mov    %esi,%eax
  800f13:	89 fa                	mov    %edi,%edx
  800f15:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800f18:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800f1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  800f1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  800f21:	eb 36                	jmp    800f59 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800f23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f26:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2c:	01 c2                	add    %eax,%edx
  800f2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f31:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f37:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  800f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f3d:	89 c1                	mov    %eax,%ecx
  800f3f:	89 d8                	mov    %ebx,%eax
  800f41:	89 d6                	mov    %edx,%esi
  800f43:	89 c7                	mov    %eax,%edi
  800f45:	fd                   	std    
  800f46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f48:	fc                   	cld    
  800f49:	89 f8                	mov    %edi,%eax
  800f4b:	89 f2                	mov    %esi,%edx
  800f4d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800f50:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800f53:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  800f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800f59:	83 c4 30             	add    $0x30,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	83 ec 20             	sub    $0x20,%esp
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f75:	8b 45 10             	mov    0x10(%ebp),%eax
  800f78:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f7e:	c1 e8 02             	shr    $0x2,%eax
  800f81:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800f83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f89:	89 d7                	mov    %edx,%edi
  800f8b:	89 c6                	mov    %eax,%esi
  800f8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f8f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f92:	83 e1 03             	and    $0x3,%ecx
  800f95:	74 02                	je     800f99 <memcpy+0x38>
  800f97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	89 fa                	mov    %edi,%edx
  800f9d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800fa0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fa3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  800fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800fa9:	83 c4 20             	add    $0x20,%esp
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbf:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  800fc2:	eb 2e                	jmp    800ff2 <memcmp+0x42>
        if (*s1 != *s2) {
  800fc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc7:	0f b6 10             	movzbl (%eax),%edx
  800fca:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fcd:	0f b6 00             	movzbl (%eax),%eax
  800fd0:	38 c2                	cmp    %al,%dl
  800fd2:	74 18                	je     800fec <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800fd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fd7:	0f b6 00             	movzbl (%eax),%eax
  800fda:	0f b6 d0             	movzbl %al,%edx
  800fdd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fe0:	0f b6 00             	movzbl (%eax),%eax
  800fe3:	0f b6 c8             	movzbl %al,%ecx
  800fe6:	89 d0                	mov    %edx,%eax
  800fe8:	29 c8                	sub    %ecx,%eax
  800fea:	eb 18                	jmp    801004 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  800fec:	ff 45 fc             	incl   -0x4(%ebp)
  800fef:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  800ff2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff5:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ff8:	89 55 10             	mov    %edx,0x10(%ebp)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	75 c5                	jne    800fc4 <memcmp+0x14>
    }
    return 0;
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801004:	89 ec                	mov    %ebp,%esp
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 e4 f0             	and    $0xfffffff0,%esp
  80100e:	83 ec 10             	sub    $0x10,%esp
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  801011:	b8 00 00 c0 fa       	mov    $0xfac00000,%eax
  801016:	8b 00                	mov    (%eax),%eax
  801018:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101c:	c7 04 24 40 13 80 00 	movl   $0x801340,(%esp)
  801023:	e8 f8 f0 ff ff       	call   800120 <cprintf>
    panic("FAIL: T.T\n");
  801028:	c7 44 24 08 5e 13 80 	movl   $0x80135e,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 07 00 00 	movl   $0x7,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 69 13 80 00 	movl   $0x801369,(%esp)
  80103f:	e8 eb ef ff ff       	call   80002f <__panic>
