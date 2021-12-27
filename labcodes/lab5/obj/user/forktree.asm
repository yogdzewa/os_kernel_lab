
obj/__user_forktree.out:     file format elf32-i386


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
  800028:	e8 40 03 00 00       	call   80036d <umain>
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
  800049:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  800050:	e8 cb 00 00 00       	call   800120 <cprintf>
    vcprintf(fmt, ap);
  800055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	8b 45 10             	mov    0x10(%ebp),%eax
  80005f:	89 04 24             	mov    %eax,(%esp)
  800062:	e8 84 00 00 00       	call   8000eb <vcprintf>
    cprintf("\n");
  800067:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  80006e:	e8 ad 00 00 00       	call   800120 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800073:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80007a:	e8 42 02 00 00       	call   8002c1 <exit>

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
  800099:	c7 04 24 bc 10 80 00 	movl   $0x8010bc,(%esp)
  8000a0:	e8 7b 00 00 00       	call   800120 <cprintf>
    vcprintf(fmt, ap);
  8000a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8000af:	89 04 24             	mov    %eax,(%esp)
  8000b2:	e8 34 00 00 00       	call   8000eb <vcprintf>
    cprintf("\n");
  8000b7:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
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
  800114:	e8 5d 04 00 00       	call   800576 <vprintfmt>
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

008002c1 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	e8 1c ff ff ff       	call   8001ee <sys_exit>
    cprintf("BUG: exit failed.\n");
  8002d2:	c7 04 24 d8 10 80 00 	movl   $0x8010d8,(%esp)
  8002d9:	e8 42 fe ff ff       	call   800120 <cprintf>
    while (1);
  8002de:	eb fe                	jmp    8002de <exit+0x1d>

008002e0 <fork>:
}

int
fork(void) {
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8002e6:	e8 20 ff ff ff       	call   80020b <sys_fork>
}
  8002eb:	89 ec                	mov    %ebp,%esp
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <wait>:

int
wait(void) {
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  8002f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002fc:	00 
  8002fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800304:	e8 18 ff ff ff       	call   800221 <sys_wait>
}
  800309:	89 ec                	mov    %ebp,%esp
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <waitpid>:

int
waitpid(int pid, int *store) {
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800313:	8b 45 0c             	mov    0xc(%ebp),%eax
  800316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	89 04 24             	mov    %eax,(%esp)
  800320:	e8 fc fe ff ff       	call   800221 <sys_wait>
}
  800325:	89 ec                	mov    %ebp,%esp
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <yield>:

void
yield(void) {
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  80032f:	e8 11 ff ff ff       	call   800245 <sys_yield>
}
  800334:	90                   	nop
  800335:	89 ec                	mov    %ebp,%esp
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <kill>:

int
kill(int pid) {
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	89 04 24             	mov    %eax,(%esp)
  800345:	e8 11 ff ff ff       	call   80025b <sys_kill>
}
  80034a:	89 ec                	mov    %ebp,%esp
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <getpid>:

int
getpid(void) {
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800354:	e8 1f ff ff ff       	call   800278 <sys_getpid>
}
  800359:	89 ec                	mov    %ebp,%esp
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800363:	e8 43 ff ff ff       	call   8002ab <sys_pgdir>
}
  800368:	90                   	nop
  800369:	89 ec                	mov    %ebp,%esp
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  800373:	e8 f4 0c 00 00       	call   80106c <main>
  800378:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  80037b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	e8 3b ff ff ff       	call   8002c1 <exit>

00800386 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
  80038f:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800395:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800398:	b8 20 00 00 00       	mov    $0x20,%eax
  80039d:	2b 45 0c             	sub    0xc(%ebp),%eax
  8003a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8003a3:	88 c1                	mov    %al,%cl
  8003a5:	d3 ea                	shr    %cl,%edx
  8003a7:	89 d0                	mov    %edx,%eax
}
  8003a9:	89 ec                	mov    %ebp,%esp
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	83 ec 58             	sub    $0x58,%esp
  8003b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  8003bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8003c8:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  8003cb:	8b 45 18             	mov    0x18(%ebp),%eax
  8003ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8003d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8003dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8003e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003e7:	74 1c                	je     800405 <printnum+0x58>
  8003e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f1:	f7 75 e4             	divl   -0x1c(%ebp)
  8003f4:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8003f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	f7 75 e4             	divl   -0x1c(%ebp)
  800402:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800405:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800408:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80040b:	f7 75 e4             	divl   -0x1c(%ebp)
  80040e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800411:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800414:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800417:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80041a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80041d:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800420:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800423:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800426:	8b 45 18             	mov    0x18(%ebp),%eax
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
  80042e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800431:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  800434:	19 d1                	sbb    %edx,%ecx
  800436:	72 4c                	jb     800484 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  800438:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80043b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80043e:	8b 45 20             	mov    0x20(%ebp),%eax
  800441:	89 44 24 18          	mov    %eax,0x18(%esp)
  800445:	89 54 24 14          	mov    %edx,0x14(%esp)
  800449:	8b 45 18             	mov    0x18(%ebp),%eax
  80044c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800450:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800453:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800461:	89 44 24 04          	mov    %eax,0x4(%esp)
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	e8 3d ff ff ff       	call   8003ad <printnum>
  800470:	eb 1b                	jmp    80048d <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	89 44 24 04          	mov    %eax,0x4(%esp)
  800479:	8b 45 20             	mov    0x20(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	8b 45 08             	mov    0x8(%ebp),%eax
  800482:	ff d0                	call   *%eax
        while (-- width > 0)
  800484:	ff 4d 1c             	decl   0x1c(%ebp)
  800487:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80048b:	7f e5                	jg     800472 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80048d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800490:	05 04 12 80 00       	add    $0x801204,%eax
  800495:	0f b6 00             	movzbl (%eax),%eax
  800498:	0f be c0             	movsbl %al,%eax
  80049b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004a2:	89 04 24             	mov    %eax,(%esp)
  8004a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a8:	ff d0                	call   *%eax
}
  8004aa:	90                   	nop
  8004ab:	89 ec                	mov    %ebp,%esp
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    

008004af <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  8004b2:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8004b6:	7e 14                	jle    8004cc <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	8d 48 08             	lea    0x8(%eax),%ecx
  8004c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c3:	89 0a                	mov    %ecx,(%edx)
  8004c5:	8b 50 04             	mov    0x4(%eax),%edx
  8004c8:	8b 00                	mov    (%eax),%eax
  8004ca:	eb 30                	jmp    8004fc <getuint+0x4d>
    }
    else if (lflag) {
  8004cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004d0:	74 16                	je     8004e8 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  8004d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004da:	8b 55 08             	mov    0x8(%ebp),%edx
  8004dd:	89 0a                	mov    %ecx,(%edx)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e6:	eb 14                	jmp    8004fc <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f3:	89 0a                	mov    %ecx,(%edx)
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800501:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800505:	7e 14                	jle    80051b <getint+0x1d>
        return va_arg(*ap, long long);
  800507:	8b 45 08             	mov    0x8(%ebp),%eax
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	8d 48 08             	lea    0x8(%eax),%ecx
  80050f:	8b 55 08             	mov    0x8(%ebp),%edx
  800512:	89 0a                	mov    %ecx,(%edx)
  800514:	8b 50 04             	mov    0x4(%eax),%edx
  800517:	8b 00                	mov    (%eax),%eax
  800519:	eb 28                	jmp    800543 <getint+0x45>
    }
    else if (lflag) {
  80051b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80051f:	74 12                	je     800533 <getint+0x35>
        return va_arg(*ap, long);
  800521:	8b 45 08             	mov    0x8(%ebp),%eax
  800524:	8b 00                	mov    (%eax),%eax
  800526:	8d 48 04             	lea    0x4(%eax),%ecx
  800529:	8b 55 08             	mov    0x8(%ebp),%edx
  80052c:	89 0a                	mov    %ecx,(%edx)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	99                   	cltd   
  800531:	eb 10                	jmp    800543 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  800533:	8b 45 08             	mov    0x8(%ebp),%eax
  800536:	8b 00                	mov    (%eax),%eax
  800538:	8d 48 04             	lea    0x4(%eax),%ecx
  80053b:	8b 55 08             	mov    0x8(%ebp),%edx
  80053e:	89 0a                	mov    %ecx,(%edx)
  800540:	8b 00                	mov    (%eax),%eax
  800542:	99                   	cltd   
    }
}
  800543:	5d                   	pop    %ebp
  800544:	c3                   	ret    

00800545 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  80054b:	8d 45 14             	lea    0x14(%ebp),%eax
  80054e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  800551:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800554:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800558:	8b 45 10             	mov    0x10(%ebp),%eax
  80055b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800562:	89 44 24 04          	mov    %eax,0x4(%esp)
  800566:	8b 45 08             	mov    0x8(%ebp),%eax
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	e8 05 00 00 00       	call   800576 <vprintfmt>
    va_end(ap);
}
  800571:	90                   	nop
  800572:	89 ec                	mov    %ebp,%esp
  800574:	5d                   	pop    %ebp
  800575:	c3                   	ret    

00800576 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  80057b:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80057e:	eb 17                	jmp    800597 <vprintfmt+0x21>
            if (ch == '\0') {
  800580:	85 db                	test   %ebx,%ebx
  800582:	0f 84 bf 03 00 00    	je     800947 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  800588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	8b 45 08             	mov    0x8(%ebp),%eax
  800595:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800597:	8b 45 10             	mov    0x10(%ebp),%eax
  80059a:	8d 50 01             	lea    0x1(%eax),%edx
  80059d:	89 55 10             	mov    %edx,0x10(%ebp)
  8005a0:	0f b6 00             	movzbl (%eax),%eax
  8005a3:	0f b6 d8             	movzbl %al,%ebx
  8005a6:	83 fb 25             	cmp    $0x25,%ebx
  8005a9:	75 d5                	jne    800580 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  8005ab:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  8005af:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  8005bc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c6:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8005c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005cc:	8d 50 01             	lea    0x1(%eax),%edx
  8005cf:	89 55 10             	mov    %edx,0x10(%ebp)
  8005d2:	0f b6 00             	movzbl (%eax),%eax
  8005d5:	0f b6 d8             	movzbl %al,%ebx
  8005d8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8005db:	83 f8 55             	cmp    $0x55,%eax
  8005de:	0f 87 37 03 00 00    	ja     80091b <vprintfmt+0x3a5>
  8005e4:	8b 04 85 28 12 80 00 	mov    0x801228(,%eax,4),%eax
  8005eb:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  8005ed:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  8005f1:	eb d6                	jmp    8005c9 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  8005f3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  8005f7:	eb d0                	jmp    8005c9 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  8005f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800600:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800603:	89 d0                	mov    %edx,%eax
  800605:	c1 e0 02             	shl    $0x2,%eax
  800608:	01 d0                	add    %edx,%eax
  80060a:	01 c0                	add    %eax,%eax
  80060c:	01 d8                	add    %ebx,%eax
  80060e:	83 e8 30             	sub    $0x30,%eax
  800611:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800614:	8b 45 10             	mov    0x10(%ebp),%eax
  800617:	0f b6 00             	movzbl (%eax),%eax
  80061a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  80061d:	83 fb 2f             	cmp    $0x2f,%ebx
  800620:	7e 38                	jle    80065a <vprintfmt+0xe4>
  800622:	83 fb 39             	cmp    $0x39,%ebx
  800625:	7f 33                	jg     80065a <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  800627:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  80062a:	eb d4                	jmp    800600 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 00                	mov    (%eax),%eax
  800637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  80063a:	eb 1f                	jmp    80065b <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  80063c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800640:	79 87                	jns    8005c9 <vprintfmt+0x53>
                width = 0;
  800642:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800649:	e9 7b ff ff ff       	jmp    8005c9 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  80064e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800655:	e9 6f ff ff ff       	jmp    8005c9 <vprintfmt+0x53>
            goto process_precision;
  80065a:	90                   	nop

        process_precision:
            if (width < 0)
  80065b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80065f:	0f 89 64 ff ff ff    	jns    8005c9 <vprintfmt+0x53>
                width = precision, precision = -1;
  800665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800668:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80066b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800672:	e9 52 ff ff ff       	jmp    8005c9 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800677:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  80067a:	e9 4a ff ff ff       	jmp    8005c9 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80068d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800691:	89 04 24             	mov    %eax,(%esp)
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	ff d0                	call   *%eax
            break;
  800699:	e9 a4 02 00 00       	jmp    800942 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a7:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  8006a9:	85 db                	test   %ebx,%ebx
  8006ab:	79 02                	jns    8006af <vprintfmt+0x139>
                err = -err;
  8006ad:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8006af:	83 fb 18             	cmp    $0x18,%ebx
  8006b2:	7f 0b                	jg     8006bf <vprintfmt+0x149>
  8006b4:	8b 34 9d a0 11 80 00 	mov    0x8011a0(,%ebx,4),%esi
  8006bb:	85 f6                	test   %esi,%esi
  8006bd:	75 23                	jne    8006e2 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  8006bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006c3:	c7 44 24 08 15 12 80 	movl   $0x801215,0x8(%esp)
  8006ca:	00 
  8006cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	89 04 24             	mov    %eax,(%esp)
  8006d8:	e8 68 fe ff ff       	call   800545 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  8006dd:	e9 60 02 00 00       	jmp    800942 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  8006e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006e6:	c7 44 24 08 1e 12 80 	movl   $0x80121e,0x8(%esp)
  8006ed:	00 
  8006ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f8:	89 04 24             	mov    %eax,(%esp)
  8006fb:	e8 45 fe ff ff       	call   800545 <printfmt>
            break;
  800700:	e9 3d 02 00 00       	jmp    800942 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8d 50 04             	lea    0x4(%eax),%edx
  80070b:	89 55 14             	mov    %edx,0x14(%ebp)
  80070e:	8b 30                	mov    (%eax),%esi
  800710:	85 f6                	test   %esi,%esi
  800712:	75 05                	jne    800719 <vprintfmt+0x1a3>
                p = "(null)";
  800714:	be 21 12 80 00       	mov    $0x801221,%esi
            }
            if (width > 0 && padc != '-') {
  800719:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80071d:	7e 76                	jle    800795 <vprintfmt+0x21f>
  80071f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800723:	74 70                	je     800795 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	89 34 24             	mov    %esi,(%esp)
  80072f:	e8 ee 03 00 00       	call   800b22 <strnlen>
  800734:	89 c2                	mov    %eax,%edx
  800736:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800739:	29 d0                	sub    %edx,%eax
  80073b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80073e:	eb 16                	jmp    800756 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  800740:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
  800747:	89 54 24 04          	mov    %edx,0x4(%esp)
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  800753:	ff 4d e8             	decl   -0x18(%ebp)
  800756:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80075a:	7f e4                	jg     800740 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80075c:	eb 37                	jmp    800795 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  80075e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800762:	74 1f                	je     800783 <vprintfmt+0x20d>
  800764:	83 fb 1f             	cmp    $0x1f,%ebx
  800767:	7e 05                	jle    80076e <vprintfmt+0x1f8>
  800769:	83 fb 7e             	cmp    $0x7e,%ebx
  80076c:	7e 15                	jle    800783 <vprintfmt+0x20d>
                    putch('?', putdat);
  80076e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800771:	89 44 24 04          	mov    %eax,0x4(%esp)
  800775:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	ff d0                	call   *%eax
  800781:	eb 0f                	jmp    800792 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  800783:	8b 45 0c             	mov    0xc(%ebp),%eax
  800786:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078a:	89 1c 24             	mov    %ebx,(%esp)
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800792:	ff 4d e8             	decl   -0x18(%ebp)
  800795:	89 f0                	mov    %esi,%eax
  800797:	8d 70 01             	lea    0x1(%eax),%esi
  80079a:	0f b6 00             	movzbl (%eax),%eax
  80079d:	0f be d8             	movsbl %al,%ebx
  8007a0:	85 db                	test   %ebx,%ebx
  8007a2:	74 27                	je     8007cb <vprintfmt+0x255>
  8007a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a8:	78 b4                	js     80075e <vprintfmt+0x1e8>
  8007aa:	ff 4d e4             	decl   -0x1c(%ebp)
  8007ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b1:	79 ab                	jns    80075e <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  8007b3:	eb 16                	jmp    8007cb <vprintfmt+0x255>
                putch(' ', putdat);
  8007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  8007c8:	ff 4d e8             	decl   -0x18(%ebp)
  8007cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8007cf:	7f e4                	jg     8007b5 <vprintfmt+0x23f>
            }
            break;
  8007d1:	e9 6c 01 00 00       	jmp    800942 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  8007d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	e8 16 fd ff ff       	call   8004fe <getint>
  8007e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007eb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  8007ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f4:	85 d2                	test   %edx,%edx
  8007f6:	79 26                	jns    80081e <vprintfmt+0x2a8>
                putch('-', putdat);
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ff:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	ff d0                	call   *%eax
                num = -(long long)num;
  80080b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800811:	f7 d8                	neg    %eax
  800813:	83 d2 00             	adc    $0x0,%edx
  800816:	f7 da                	neg    %edx
  800818:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80081b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  80081e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800825:	e9 a8 00 00 00       	jmp    8008d2 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  80082a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80082d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	e8 73 fc ff ff       	call   8004af <getuint>
  80083c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80083f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800842:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800849:	e9 84 00 00 00       	jmp    8008d2 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  80084e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800851:	89 44 24 04          	mov    %eax,0x4(%esp)
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
  800858:	89 04 24             	mov    %eax,(%esp)
  80085b:	e8 4f fc ff ff       	call   8004af <getuint>
  800860:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800863:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800866:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  80086d:	eb 63                	jmp    8008d2 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	89 44 24 04          	mov    %eax,0x4(%esp)
  800876:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	ff d0                	call   *%eax
            putch('x', putdat);
  800882:	8b 45 0c             	mov    0xc(%ebp),%eax
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8d 50 04             	lea    0x4(%eax),%edx
  80089b:	89 55 14             	mov    %edx,0x14(%ebp)
  80089e:	8b 00                	mov    (%eax),%eax
  8008a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  8008aa:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  8008b1:	eb 1f                	jmp    8008d2 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  8008b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8008bd:	89 04 24             	mov    %eax,(%esp)
  8008c0:	e8 ea fb ff ff       	call   8004af <getuint>
  8008c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  8008cb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  8008d2:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8008d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d9:	89 54 24 18          	mov    %edx,0x18(%esp)
  8008dd:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8008e0:	89 54 24 14          	mov    %edx,0x14(%esp)
  8008e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8008e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	89 04 24             	mov    %eax,(%esp)
  800903:	e8 a5 fa ff ff       	call   8003ad <printnum>
            break;
  800908:	eb 38                	jmp    800942 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  80090a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800911:	89 1c 24             	mov    %ebx,(%esp)
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	ff d0                	call   *%eax
            break;
  800919:	eb 27                	jmp    800942 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  80092e:	ff 4d 10             	decl   0x10(%ebp)
  800931:	eb 03                	jmp    800936 <vprintfmt+0x3c0>
  800933:	ff 4d 10             	decl   0x10(%ebp)
  800936:	8b 45 10             	mov    0x10(%ebp),%eax
  800939:	48                   	dec    %eax
  80093a:	0f b6 00             	movzbl (%eax),%eax
  80093d:	3c 25                	cmp    $0x25,%al
  80093f:	75 f2                	jne    800933 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  800941:	90                   	nop
    while (1) {
  800942:	e9 37 fc ff ff       	jmp    80057e <vprintfmt+0x8>
                return;
  800947:	90                   	nop
        }
    }
}
  800948:	83 c4 40             	add    $0x40,%esp
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	8b 40 08             	mov    0x8(%eax),%eax
  800958:	8d 50 01             	lea    0x1(%eax),%edx
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	8b 10                	mov    (%eax),%edx
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	8b 40 04             	mov    0x4(%eax),%eax
  80096c:	39 c2                	cmp    %eax,%edx
  80096e:	73 12                	jae    800982 <sprintputch+0x33>
        *b->buf ++ = ch;
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
  800973:	8b 00                	mov    (%eax),%eax
  800975:	8d 48 01             	lea    0x1(%eax),%ecx
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	89 0a                	mov    %ecx,(%edx)
  80097d:	8b 55 08             	mov    0x8(%ebp),%edx
  800980:	88 10                	mov    %dl,(%eax)
    }
}
  800982:	90                   	nop
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  80098b:	8d 45 14             	lea    0x14(%ebp),%eax
  80098e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800991:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800994:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800998:	8b 45 10             	mov    0x10(%ebp),%eax
  80099b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 0a 00 00 00       	call   8009bb <vsnprintf>
  8009b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  8009b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009b7:	89 ec                	mov    %ebp,%esp
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ca:	8d 50 ff             	lea    -0x1(%eax),%edx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	01 d0                	add    %edx,%eax
  8009d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  8009dc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8009e0:	74 0a                	je     8009ec <vsnprintf+0x31>
  8009e2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8009e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009e8:	39 c2                	cmp    %eax,%edx
  8009ea:	76 07                	jbe    8009f3 <vsnprintf+0x38>
        return -E_INVAL;
  8009ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f1:	eb 2a                	jmp    800a1d <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	c7 04 24 4f 09 80 00 	movl   $0x80094f,(%esp)
  800a0f:	e8 62 fb ff ff       	call   800576 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800a14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a17:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a1d:	89 ec                	mov    %ebp,%esp
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800a2a:	a1 00 20 80 00       	mov    0x802000,%eax
  800a2f:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800a35:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800a3b:	6b f0 05             	imul   $0x5,%eax,%esi
  800a3e:	01 fe                	add    %edi,%esi
  800a40:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  800a45:	f7 e7                	mul    %edi
  800a47:	01 d6                	add    %edx,%esi
  800a49:	89 f2                	mov    %esi,%edx
  800a4b:	83 c0 0b             	add    $0xb,%eax
  800a4e:	83 d2 00             	adc    $0x0,%edx
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	83 e7 ff             	and    $0xffffffff,%edi
  800a56:	89 f9                	mov    %edi,%ecx
  800a58:	0f b7 da             	movzwl %dx,%ebx
  800a5b:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800a61:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800a67:	a1 00 20 80 00       	mov    0x802000,%eax
  800a6c:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800a72:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800a76:	c1 ea 0c             	shr    $0xc,%edx
  800a79:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a7c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800a7f:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800a92:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a95:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a98:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800a9c:	74 1c                	je     800aba <rand+0x99>
  800a9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	f7 75 dc             	divl   -0x24(%ebp)
  800aa9:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab4:	f7 75 dc             	divl   -0x24(%ebp)
  800ab7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800aba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800abd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ac0:	f7 75 dc             	divl   -0x24(%ebp)
  800ac3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ac9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800acc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800acf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ad2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ad5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800ad8:	83 c4 24             	add    $0x24,%esp
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
    next = seed;
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	a3 00 20 80 00       	mov    %eax,0x802000
  800af0:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800af6:	90                   	nop
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800aff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  800b06:	eb 03                	jmp    800b0b <strlen+0x12>
        cnt ++;
  800b08:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8d 50 01             	lea    0x1(%eax),%edx
  800b11:	89 55 08             	mov    %edx,0x8(%ebp)
  800b14:	0f b6 00             	movzbl (%eax),%eax
  800b17:	84 c0                	test   %al,%al
  800b19:	75 ed                	jne    800b08 <strlen+0xf>
    }
    return cnt;
  800b1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b1e:	89 ec                	mov    %ebp,%esp
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800b28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x12>
        cnt ++;
  800b31:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800b34:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b37:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800b3a:	73 10                	jae    800b4c <strnlen+0x2a>
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8d 50 01             	lea    0x1(%eax),%edx
  800b42:	89 55 08             	mov    %edx,0x8(%ebp)
  800b45:	0f b6 00             	movzbl (%eax),%eax
  800b48:	84 c0                	test   %al,%al
  800b4a:	75 e5                	jne    800b31 <strnlen+0xf>
    }
    return cnt;
  800b4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b4f:	89 ec                	mov    %ebp,%esp
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	83 ec 20             	sub    $0x20,%esp
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b64:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800b67:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	89 ce                	mov    %ecx,%esi
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	ac                   	lods   %ds:(%esi),%al
  800b76:	aa                   	stos   %al,%es:(%edi)
  800b77:	84 c0                	test   %al,%al
  800b79:	75 fa                	jne    800b75 <strcpy+0x22>
  800b7b:	89 fa                	mov    %edi,%edx
  800b7d:	89 f1                	mov    %esi,%ecx
  800b7f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800b82:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800b85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800b8b:	83 c4 20             	add    $0x20,%esp
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800b9e:	eb 1e                	jmp    800bbe <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  800ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba3:	0f b6 10             	movzbl (%eax),%edx
  800ba6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ba9:	88 10                	mov    %dl,(%eax)
  800bab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bae:	0f b6 00             	movzbl (%eax),%eax
  800bb1:	84 c0                	test   %al,%al
  800bb3:	74 03                	je     800bb8 <strncpy+0x26>
            src ++;
  800bb5:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  800bb8:	ff 45 fc             	incl   -0x4(%ebp)
  800bbb:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  800bbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bc2:	75 dc                	jne    800ba0 <strncpy+0xe>
    }
    return dst;
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bc7:	89 ec                	mov    %ebp,%esp
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	83 ec 20             	sub    $0x20,%esp
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  800bdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 c2                	mov    %eax,%edx
  800be9:	89 ce                	mov    %ecx,%esi
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	ac                   	lods   %ds:(%esi),%al
  800bee:	ae                   	scas   %es:(%edi),%al
  800bef:	75 08                	jne    800bf9 <strcmp+0x2e>
  800bf1:	84 c0                	test   %al,%al
  800bf3:	75 f8                	jne    800bed <strcmp+0x22>
  800bf5:	31 c0                	xor    %eax,%eax
  800bf7:	eb 04                	jmp    800bfd <strcmp+0x32>
  800bf9:	19 c0                	sbb    %eax,%eax
  800bfb:	0c 01                	or     $0x1,%al
  800bfd:	89 fa                	mov    %edi,%edx
  800bff:	89 f1                	mov    %esi,%ecx
  800c01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c04:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800c07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  800c0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  800c0d:	83 c4 20             	add    $0x20,%esp
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800c17:	eb 09                	jmp    800c22 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  800c19:	ff 4d 10             	decl   0x10(%ebp)
  800c1c:	ff 45 08             	incl   0x8(%ebp)
  800c1f:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800c22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c26:	74 1a                	je     800c42 <strncmp+0x2e>
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2b:	0f b6 00             	movzbl (%eax),%eax
  800c2e:	84 c0                	test   %al,%al
  800c30:	74 10                	je     800c42 <strncmp+0x2e>
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	0f b6 10             	movzbl (%eax),%edx
  800c38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3b:	0f b6 00             	movzbl (%eax),%eax
  800c3e:	38 c2                	cmp    %al,%dl
  800c40:	74 d7                	je     800c19 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800c42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c46:	74 18                	je     800c60 <strncmp+0x4c>
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	0f b6 00             	movzbl (%eax),%eax
  800c4e:	0f b6 d0             	movzbl %al,%edx
  800c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c54:	0f b6 00             	movzbl (%eax),%eax
  800c57:	0f b6 c8             	movzbl %al,%ecx
  800c5a:	89 d0                	mov    %edx,%eax
  800c5c:	29 c8                	sub    %ecx,%eax
  800c5e:	eb 05                	jmp    800c65 <strncmp+0x51>
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 04             	sub    $0x4,%esp
  800c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c70:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800c73:	eb 13                	jmp    800c88 <strchr+0x21>
        if (*s == c) {
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	0f b6 00             	movzbl (%eax),%eax
  800c7b:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800c7e:	75 05                	jne    800c85 <strchr+0x1e>
            return (char *)s;
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	eb 12                	jmp    800c97 <strchr+0x30>
        }
        s ++;
  800c85:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	0f b6 00             	movzbl (%eax),%eax
  800c8e:	84 c0                	test   %al,%al
  800c90:	75 e3                	jne    800c75 <strchr+0xe>
    }
    return NULL;
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c97:	89 ec                	mov    %ebp,%esp
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 04             	sub    $0x4,%esp
  800ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca4:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800ca7:	eb 0e                	jmp    800cb7 <strfind+0x1c>
        if (*s == c) {
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	0f b6 00             	movzbl (%eax),%eax
  800caf:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800cb2:	74 0f                	je     800cc3 <strfind+0x28>
            break;
        }
        s ++;
  800cb4:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	0f b6 00             	movzbl (%eax),%eax
  800cbd:	84 c0                	test   %al,%al
  800cbf:	75 e8                	jne    800ca9 <strfind+0xe>
  800cc1:	eb 01                	jmp    800cc4 <strfind+0x29>
            break;
  800cc3:	90                   	nop
    }
    return (char *)s;
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cc7:	89 ec                	mov    %ebp,%esp
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800cd1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800cd8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800cdf:	eb 03                	jmp    800ce4 <strtol+0x19>
        s ++;
  800ce1:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	0f b6 00             	movzbl (%eax),%eax
  800cea:	3c 20                	cmp    $0x20,%al
  800cec:	74 f3                	je     800ce1 <strtol+0x16>
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 00             	movzbl (%eax),%eax
  800cf4:	3c 09                	cmp    $0x9,%al
  800cf6:	74 e9                	je     800ce1 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	0f b6 00             	movzbl (%eax),%eax
  800cfe:	3c 2b                	cmp    $0x2b,%al
  800d00:	75 05                	jne    800d07 <strtol+0x3c>
        s ++;
  800d02:	ff 45 08             	incl   0x8(%ebp)
  800d05:	eb 14                	jmp    800d1b <strtol+0x50>
    }
    else if (*s == '-') {
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	0f b6 00             	movzbl (%eax),%eax
  800d0d:	3c 2d                	cmp    $0x2d,%al
  800d0f:	75 0a                	jne    800d1b <strtol+0x50>
        s ++, neg = 1;
  800d11:	ff 45 08             	incl   0x8(%ebp)
  800d14:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  800d1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d1f:	74 06                	je     800d27 <strtol+0x5c>
  800d21:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d25:	75 22                	jne    800d49 <strtol+0x7e>
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	0f b6 00             	movzbl (%eax),%eax
  800d2d:	3c 30                	cmp    $0x30,%al
  800d2f:	75 18                	jne    800d49 <strtol+0x7e>
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	40                   	inc    %eax
  800d35:	0f b6 00             	movzbl (%eax),%eax
  800d38:	3c 78                	cmp    $0x78,%al
  800d3a:	75 0d                	jne    800d49 <strtol+0x7e>
        s += 2, base = 16;
  800d3c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d40:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d47:	eb 29                	jmp    800d72 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  800d49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d4d:	75 16                	jne    800d65 <strtol+0x9a>
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	0f b6 00             	movzbl (%eax),%eax
  800d55:	3c 30                	cmp    $0x30,%al
  800d57:	75 0c                	jne    800d65 <strtol+0x9a>
        s ++, base = 8;
  800d59:	ff 45 08             	incl   0x8(%ebp)
  800d5c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d63:	eb 0d                	jmp    800d72 <strtol+0xa7>
    }
    else if (base == 0) {
  800d65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d69:	75 07                	jne    800d72 <strtol+0xa7>
        base = 10;
  800d6b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	0f b6 00             	movzbl (%eax),%eax
  800d78:	3c 2f                	cmp    $0x2f,%al
  800d7a:	7e 1b                	jle    800d97 <strtol+0xcc>
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	0f b6 00             	movzbl (%eax),%eax
  800d82:	3c 39                	cmp    $0x39,%al
  800d84:	7f 11                	jg     800d97 <strtol+0xcc>
            dig = *s - '0';
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	0f b6 00             	movzbl (%eax),%eax
  800d8c:	0f be c0             	movsbl %al,%eax
  800d8f:	83 e8 30             	sub    $0x30,%eax
  800d92:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d95:	eb 48                	jmp    800ddf <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	0f b6 00             	movzbl (%eax),%eax
  800d9d:	3c 60                	cmp    $0x60,%al
  800d9f:	7e 1b                	jle    800dbc <strtol+0xf1>
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	0f b6 00             	movzbl (%eax),%eax
  800da7:	3c 7a                	cmp    $0x7a,%al
  800da9:	7f 11                	jg     800dbc <strtol+0xf1>
            dig = *s - 'a' + 10;
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	0f be c0             	movsbl %al,%eax
  800db4:	83 e8 57             	sub    $0x57,%eax
  800db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dba:	eb 23                	jmp    800ddf <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	0f b6 00             	movzbl (%eax),%eax
  800dc2:	3c 40                	cmp    $0x40,%al
  800dc4:	7e 3b                	jle    800e01 <strtol+0x136>
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	0f b6 00             	movzbl (%eax),%eax
  800dcc:	3c 5a                	cmp    $0x5a,%al
  800dce:	7f 31                	jg     800e01 <strtol+0x136>
            dig = *s - 'A' + 10;
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	0f b6 00             	movzbl (%eax),%eax
  800dd6:	0f be c0             	movsbl %al,%eax
  800dd9:	83 e8 37             	sub    $0x37,%eax
  800ddc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de2:	3b 45 10             	cmp    0x10(%ebp),%eax
  800de5:	7d 19                	jge    800e00 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  800de7:	ff 45 08             	incl   0x8(%ebp)
  800dea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ded:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df6:	01 d0                	add    %edx,%eax
  800df8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  800dfb:	e9 72 ff ff ff       	jmp    800d72 <strtol+0xa7>
            break;
  800e00:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  800e01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e05:	74 08                	je     800e0f <strtol+0x144>
        *endptr = (char *) s;
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  800e0f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e13:	74 07                	je     800e1c <strtol+0x151>
  800e15:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e18:	f7 d8                	neg    %eax
  800e1a:	eb 03                	jmp    800e1f <strtol+0x154>
  800e1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e1f:	89 ec                	mov    %ebp,%esp
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 28             	sub    $0x28,%esp
  800e29:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2f:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800e32:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800e3c:	88 55 f7             	mov    %dl,-0x9(%ebp)
  800e3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e42:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800e45:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800e4c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800e4f:	89 d7                	mov    %edx,%edi
  800e51:	f3 aa                	rep stos %al,%es:(%edi)
  800e53:	89 fa                	mov    %edi,%edx
  800e55:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800e58:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800e5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800e5e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e61:	89 ec                	mov    %ebp,%esp
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 30             	sub    $0x30,%esp
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7d:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e83:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e86:	73 42                	jae    800eca <memmove+0x65>
  800e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e91:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e94:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e97:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800e9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800e9d:	c1 e8 02             	shr    $0x2,%eax
  800ea0:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800ea2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ea5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ea8:	89 d7                	mov    %edx,%edi
  800eaa:	89 c6                	mov    %eax,%esi
  800eac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800eb1:	83 e1 03             	and    $0x3,%ecx
  800eb4:	74 02                	je     800eb8 <memmove+0x53>
  800eb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800eb8:	89 f0                	mov    %esi,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800ebf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ec2:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  800ec5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  800ec8:	eb 36                	jmp    800f00 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800eca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ecd:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ed3:	01 c2                	add    %eax,%edx
  800ed5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ed8:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ede:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  800ee1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ee4:	89 c1                	mov    %eax,%ecx
  800ee6:	89 d8                	mov    %ebx,%eax
  800ee8:	89 d6                	mov    %edx,%esi
  800eea:	89 c7                	mov    %eax,%edi
  800eec:	fd                   	std    
  800eed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800eef:	fc                   	cld    
  800ef0:	89 f8                	mov    %edi,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800ef7:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800efa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  800efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800f00:	83 c4 30             	add    $0x30,%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	83 ec 20             	sub    $0x20,%esp
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f25:	c1 e8 02             	shr    $0x2,%eax
  800f28:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800f2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f30:	89 d7                	mov    %edx,%edi
  800f32:	89 c6                	mov    %eax,%esi
  800f34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f36:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800f39:	83 e1 03             	and    $0x3,%ecx
  800f3c:	74 02                	je     800f40 <memcpy+0x38>
  800f3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	89 fa                	mov    %edi,%edx
  800f44:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800f47:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  800f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800f50:	83 c4 20             	add    $0x20,%esp
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f60:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800f63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f66:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  800f69:	eb 2e                	jmp    800f99 <memcmp+0x42>
        if (*s1 != *s2) {
  800f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f6e:	0f b6 10             	movzbl (%eax),%edx
  800f71:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f74:	0f b6 00             	movzbl (%eax),%eax
  800f77:	38 c2                	cmp    %al,%dl
  800f79:	74 18                	je     800f93 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800f7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f7e:	0f b6 00             	movzbl (%eax),%eax
  800f81:	0f b6 d0             	movzbl %al,%edx
  800f84:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f87:	0f b6 00             	movzbl (%eax),%eax
  800f8a:	0f b6 c8             	movzbl %al,%ecx
  800f8d:	89 d0                	mov    %edx,%eax
  800f8f:	29 c8                	sub    %ecx,%eax
  800f91:	eb 18                	jmp    800fab <memcmp+0x54>
        }
        s1 ++, s2 ++;
  800f93:	ff 45 fc             	incl   -0x4(%ebp)
  800f96:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  800f99:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9c:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f9f:	89 55 10             	mov    %edx,0x10(%ebp)
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	75 c5                	jne    800f6b <memcmp+0x14>
    }
    return 0;
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fab:	89 ec                	mov    %ebp,%esp
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <forkchild>:
#define DEPTH 4

void forktree(const char *cur);

void
forkchild(const char *cur, char branch) {
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 48             	sub    $0x48,%esp
  800fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb8:	88 45 e4             	mov    %al,-0x1c(%ebp)
    char nxt[DEPTH + 1];

    if (strlen(cur) >= DEPTH)
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	89 04 24             	mov    %eax,(%esp)
  800fc1:	e8 33 fb ff ff       	call   800af9 <strlen>
  800fc6:	83 f8 03             	cmp    $0x3,%eax
  800fc9:	77 4f                	ja     80101a <forkchild+0x6b>
        return;

    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800fcb:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800fcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fda:	c7 44 24 08 80 13 80 	movl   $0x801380,0x8(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800fe9:	00 
  800fea:	8d 45 f3             	lea    -0xd(%ebp),%eax
  800fed:	89 04 24             	mov    %eax,(%esp)
  800ff0:	e8 90 f9 ff ff       	call   800985 <snprintf>
    if (fork() == 0) {
  800ff5:	e8 e6 f2 ff ff       	call   8002e0 <fork>
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	75 1d                	jne    80101b <forkchild+0x6c>
        forktree(nxt);
  800ffe:	8d 45 f3             	lea    -0xd(%ebp),%eax
  801001:	89 04 24             	mov    %eax,(%esp)
  801004:	e8 16 00 00 00       	call   80101f <forktree>
        yield();
  801009:	e8 1b f3 ff ff       	call   800329 <yield>
        exit(0);
  80100e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801015:	e8 a7 f2 ff ff       	call   8002c1 <exit>
        return;
  80101a:	90                   	nop
    }
}
  80101b:	89 ec                	mov    %ebp,%esp
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <forktree>:

void
forktree(const char *cur) {
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 18             	sub    $0x18,%esp
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  801025:	e8 24 f3 ff ff       	call   80034e <getpid>
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801031:	89 44 24 04          	mov    %eax,0x4(%esp)
  801035:	c7 04 24 85 13 80 00 	movl   $0x801385,(%esp)
  80103c:	e8 df f0 ff ff       	call   800120 <cprintf>

    forkchild(cur, '0');
  801041:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801048:	00 
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	89 04 24             	mov    %eax,(%esp)
  80104f:	e8 5b ff ff ff       	call   800faf <forkchild>
    forkchild(cur, '1');
  801054:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80105b:	00 
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	89 04 24             	mov    %eax,(%esp)
  801062:	e8 48 ff ff ff       	call   800faf <forkchild>
}
  801067:	90                   	nop
  801068:	89 ec                	mov    %ebp,%esp
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <main>:

int
main(void) {
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 e4 f0             	and    $0xfffffff0,%esp
  801072:	83 ec 10             	sub    $0x10,%esp
    forktree("");
  801075:	c7 04 24 96 13 80 00 	movl   $0x801396,(%esp)
  80107c:	e8 9e ff ff ff       	call   80101f <forktree>
    return 0;
  801081:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801086:	89 ec                	mov    %ebp,%esp
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    
