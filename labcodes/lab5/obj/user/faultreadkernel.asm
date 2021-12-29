
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
  800028:	e8 d7 02 00 00       	call   800304 <umain>
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
  800032:	83 ec 18             	sub    $0x18,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800035:	8d 45 14             	lea    0x14(%ebp),%eax
  800038:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	ff 75 0c             	pushl  0xc(%ebp)
  800041:	ff 75 08             	pushl  0x8(%ebp)
  800044:	68 20 0f 80 00       	push   $0x800f20
  800049:	e8 c3 00 00 00       	call   800111 <cprintf>
  80004e:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  800051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800054:	83 ec 08             	sub    $0x8,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 10             	pushl  0x10(%ebp)
  80005b:	e8 88 00 00 00       	call   8000e8 <vcprintf>
  800060:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	68 3a 0f 80 00       	push   $0x800f3a
  80006b:	e8 a1 00 00 00       	call   800111 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
    exit(-E_PANIC);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	6a f6                	push   $0xfffffff6
  800078:	e8 e5 01 00 00       	call   800262 <exit>

0080007d <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  800083:	8d 45 14             	lea    0x14(%ebp),%eax
  800086:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  800089:	83 ec 04             	sub    $0x4,%esp
  80008c:	ff 75 0c             	pushl  0xc(%ebp)
  80008f:	ff 75 08             	pushl  0x8(%ebp)
  800092:	68 3c 0f 80 00       	push   $0x800f3c
  800097:	e8 75 00 00 00       	call   800111 <cprintf>
  80009c:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  80009f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a2:	83 ec 08             	sub    $0x8,%esp
  8000a5:	50                   	push   %eax
  8000a6:	ff 75 10             	pushl  0x10(%ebp)
  8000a9:	e8 3a 00 00 00       	call   8000e8 <vcprintf>
  8000ae:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 3a 0f 80 00       	push   $0x800f3a
  8000b9:	e8 53 00 00 00       	call   800111 <cprintf>
  8000be:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  8000c1:	90                   	nop
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 08             	sub    $0x8,%esp
    sys_putc(c);
  8000ca:	83 ec 0c             	sub    $0xc,%esp
  8000cd:	ff 75 08             	pushl  0x8(%ebp)
  8000d0:	e8 6c 01 00 00       	call   800241 <sys_putc>
  8000d5:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  8000d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000db:	8b 00                	mov    (%eax),%eax
  8000dd:	8d 50 01             	lea    0x1(%eax),%edx
  8000e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e3:	89 10                	mov    %edx,(%eax)
}
  8000e5:	90                   	nop
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  8000ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000f5:	ff 75 0c             	pushl  0xc(%ebp)
  8000f8:	ff 75 08             	pushl  0x8(%ebp)
  8000fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000fe:	50                   	push   %eax
  8000ff:	68 c4 00 80 00       	push   $0x8000c4
  800104:	e8 df 03 00 00       	call   8004e8 <vprintfmt>
  800109:	83 c4 10             	add    $0x10,%esp
    return cnt;
  80010c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  800117:	8d 45 0c             	lea    0xc(%ebp),%eax
  80011a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  80011d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	50                   	push   %eax
  800124:	ff 75 08             	pushl  0x8(%ebp)
  800127:	e8 bc ff ff ff       	call   8000e8 <vcprintf>
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800132:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  80013d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800144:	eb 14                	jmp    80015a <cputs+0x23>
        cputch(c, &cnt);
  800146:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80014a:	83 ec 08             	sub    $0x8,%esp
  80014d:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800150:	52                   	push   %edx
  800151:	50                   	push   %eax
  800152:	e8 6d ff ff ff       	call   8000c4 <cputch>
  800157:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8d 50 01             	lea    0x1(%eax),%edx
  800160:	89 55 08             	mov    %edx,0x8(%ebp)
  800163:	0f b6 00             	movzbl (%eax),%eax
  800166:	88 45 f7             	mov    %al,-0x9(%ebp)
  800169:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  80016d:	75 d7                	jne    800146 <cputs+0xf>
    }
    cputch('\n', &cnt);
  80016f:	83 ec 08             	sub    $0x8,%esp
  800172:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800175:	50                   	push   %eax
  800176:	6a 0a                	push   $0xa
  800178:	e8 47 ff ff ff       	call   8000c4 <cputch>
  80017d:	83 c4 10             	add    $0x10,%esp
    return cnt;
  800180:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  80018e:	8d 45 0c             	lea    0xc(%ebp),%eax
  800191:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  800194:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80019b:	eb 16                	jmp    8001b3 <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  80019d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8001a0:	8d 50 04             	lea    0x4(%eax),%edx
  8001a3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001a6:	8b 10                	mov    (%eax),%edx
  8001a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001ab:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
    for (i = 0; i < MAX_ARGS; i ++) {
  8001af:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8001b3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8001b7:	7e e4                	jle    80019d <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8001b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8001bc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8001bf:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8001c2:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8001c5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    asm volatile (
  8001c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cb:	cd 80                	int    $0x80
  8001cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "cc", "memory");
    return ret;
  8001d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  8001d3:	83 c4 20             	add    $0x20,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_exit>:

int
sys_exit(int error_code) {
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_exit, error_code);
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	6a 01                	push   $0x1
  8001e3:	e8 9d ff ff ff       	call   800185 <syscall>
  8001e8:	83 c4 08             	add    $0x8,%esp
}
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    

008001ed <sys_fork>:

int
sys_fork(void) {
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_fork);
  8001f0:	6a 02                	push   $0x2
  8001f2:	e8 8e ff ff ff       	call   800185 <syscall>
  8001f7:	83 c4 04             	add    $0x4,%esp
}
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <sys_wait>:

int
sys_wait(int pid, int *store) {
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_wait, pid, store);
  8001ff:	ff 75 0c             	pushl  0xc(%ebp)
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	6a 03                	push   $0x3
  800207:	e8 79 ff ff ff       	call   800185 <syscall>
  80020c:	83 c4 0c             	add    $0xc,%esp
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <sys_yield>:

int
sys_yield(void) {
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_yield);
  800214:	6a 0a                	push   $0xa
  800216:	e8 6a ff ff ff       	call   800185 <syscall>
  80021b:	83 c4 04             	add    $0x4,%esp
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_kill>:

int
sys_kill(int pid) {
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_kill, pid);
  800223:	ff 75 08             	pushl  0x8(%ebp)
  800226:	6a 0c                	push   $0xc
  800228:	e8 58 ff ff ff       	call   800185 <syscall>
  80022d:	83 c4 08             	add    $0x8,%esp
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <sys_getpid>:

int
sys_getpid(void) {
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_getpid);
  800235:	6a 12                	push   $0x12
  800237:	e8 49 ff ff ff       	call   800185 <syscall>
  80023c:	83 c4 04             	add    $0x4,%esp
}
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <sys_putc>:

int
sys_putc(int c) {
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_putc, c);
  800244:	ff 75 08             	pushl  0x8(%ebp)
  800247:	6a 1e                	push   $0x1e
  800249:	e8 37 ff ff ff       	call   800185 <syscall>
  80024e:	83 c4 08             	add    $0x8,%esp
}
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <sys_pgdir>:

int
sys_pgdir(void) {
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_pgdir);
  800256:	6a 1f                	push   $0x1f
  800258:	e8 28 ff ff ff       	call   800185 <syscall>
  80025d:	83 c4 04             	add    $0x4,%esp
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	83 ec 08             	sub    $0x8,%esp
    sys_exit(error_code);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	e8 68 ff ff ff       	call   8001db <sys_exit>
  800273:	83 c4 10             	add    $0x10,%esp
    cprintf("BUG: exit failed.\n");
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	68 58 0f 80 00       	push   $0x800f58
  80027e:	e8 8e fe ff ff       	call   800111 <cprintf>
  800283:	83 c4 10             	add    $0x10,%esp
    while (1);
  800286:	eb fe                	jmp    800286 <exit+0x24>

00800288 <fork>:
}

int
fork(void) {
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  80028e:	e8 5a ff ff ff       	call   8001ed <sys_fork>
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <wait>:

int
wait(void) {
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
    return sys_wait(0, NULL);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	6a 00                	push   $0x0
  8002a0:	6a 00                	push   $0x0
  8002a2:	e8 55 ff ff ff       	call   8001fc <sys_wait>
  8002a7:	83 c4 10             	add    $0x10,%esp
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <waitpid>:

int
waitpid(int pid, int *store) {
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 08             	sub    $0x8,%esp
    return sys_wait(pid, store);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	ff 75 0c             	pushl  0xc(%ebp)
  8002b8:	ff 75 08             	pushl  0x8(%ebp)
  8002bb:	e8 3c ff ff ff       	call   8001fc <sys_wait>
  8002c0:	83 c4 10             	add    $0x10,%esp
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <yield>:

void
yield(void) {
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  8002cb:	e8 41 ff ff ff       	call   800211 <sys_yield>
}
  8002d0:	90                   	nop
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <kill>:

int
kill(int pid) {
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	83 ec 08             	sub    $0x8,%esp
    return sys_kill(pid);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	ff 75 08             	pushl  0x8(%ebp)
  8002df:	e8 3c ff ff ff       	call   800220 <sys_kill>
  8002e4:	83 c4 10             	add    $0x10,%esp
}
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <getpid>:

int
getpid(void) {
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  8002ef:	e8 3e ff ff ff       	call   800232 <sys_getpid>
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  8002fc:	e8 52 ff ff ff       	call   800253 <sys_pgdir>
}
  800301:	90                   	nop
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 18             	sub    $0x18,%esp
    int ret = main();
  80030a:	e8 c9 0b 00 00       	call   800ed8 <main>
  80030f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	ff 75 f4             	pushl  -0xc(%ebp)
  800318:	e8 45 ff ff ff       	call   800262 <exit>

0080031d <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  80032c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  80032f:	b8 20 00 00 00       	mov    $0x20,%eax
  800334:	2b 45 0c             	sub    0xc(%ebp),%eax
  800337:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80033a:	89 c1                	mov    %eax,%ecx
  80033c:	d3 ea                	shr    %cl,%edx
  80033e:	89 d0                	mov    %edx,%eax
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 38             	sub    $0x38,%esp
  800348:	8b 45 10             	mov    0x10(%ebp),%eax
  80034b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80034e:	8b 45 14             	mov    0x14(%ebp),%eax
  800351:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800354:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800357:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80035a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80035d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800360:	8b 45 18             	mov    0x18(%ebp),%eax
  800363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800366:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800369:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036f:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800375:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800378:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80037c:	74 1c                	je     80039a <printnum+0x58>
  80037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
  800386:	f7 75 e4             	divl   -0x1c(%ebp)
  800389:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80038c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80038f:	ba 00 00 00 00       	mov    $0x0,%edx
  800394:	f7 75 e4             	divl   -0x1c(%ebp)
  800397:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80039a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003a0:	f7 75 e4             	divl   -0x1c(%ebp)
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8003af:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8003b2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8003b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8003bb:	8b 45 18             	mov    0x18(%ebp),%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8003c6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  8003c9:	19 d1                	sbb    %edx,%ecx
  8003cb:	72 37                	jb     800404 <printnum+0xc2>
        printnum(putch, putdat, result, base, width - 1, padc);
  8003cd:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8003d0:	83 e8 01             	sub    $0x1,%eax
  8003d3:	83 ec 04             	sub    $0x4,%esp
  8003d6:	ff 75 20             	pushl  0x20(%ebp)
  8003d9:	50                   	push   %eax
  8003da:	ff 75 18             	pushl  0x18(%ebp)
  8003dd:	ff 75 ec             	pushl  -0x14(%ebp)
  8003e0:	ff 75 e8             	pushl  -0x18(%ebp)
  8003e3:	ff 75 0c             	pushl  0xc(%ebp)
  8003e6:	ff 75 08             	pushl  0x8(%ebp)
  8003e9:	e8 54 ff ff ff       	call   800342 <printnum>
  8003ee:	83 c4 20             	add    $0x20,%esp
  8003f1:	eb 1b                	jmp    80040e <printnum+0xcc>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	ff 75 0c             	pushl  0xc(%ebp)
  8003f9:	ff 75 20             	pushl  0x20(%ebp)
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	ff d0                	call   *%eax
  800401:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
  800404:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800408:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80040c:	7f e5                	jg     8003f3 <printnum+0xb1>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80040e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800411:	05 84 10 80 00       	add    $0x801084,%eax
  800416:	0f b6 00             	movzbl (%eax),%eax
  800419:	0f be c0             	movsbl %al,%eax
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	ff 75 0c             	pushl  0xc(%ebp)
  800422:	50                   	push   %eax
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	ff d0                	call   *%eax
  800428:	83 c4 10             	add    $0x10,%esp
}
  80042b:	90                   	nop
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800431:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800435:	7e 14                	jle    80044b <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	8d 48 08             	lea    0x8(%eax),%ecx
  80043f:	8b 55 08             	mov    0x8(%ebp),%edx
  800442:	89 0a                	mov    %ecx,(%edx)
  800444:	8b 50 04             	mov    0x4(%eax),%edx
  800447:	8b 00                	mov    (%eax),%eax
  800449:	eb 30                	jmp    80047b <getuint+0x4d>
    }
    else if (lflag) {
  80044b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80044f:	74 16                	je     800467 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	8b 00                	mov    (%eax),%eax
  800456:	8d 48 04             	lea    0x4(%eax),%ecx
  800459:	8b 55 08             	mov    0x8(%ebp),%edx
  80045c:	89 0a                	mov    %ecx,(%edx)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	ba 00 00 00 00       	mov    $0x0,%edx
  800465:	eb 14                	jmp    80047b <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	8d 48 04             	lea    0x4(%eax),%ecx
  80046f:	8b 55 08             	mov    0x8(%ebp),%edx
  800472:	89 0a                	mov    %ecx,(%edx)
  800474:	8b 00                	mov    (%eax),%eax
  800476:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  80047b:	5d                   	pop    %ebp
  80047c:	c3                   	ret    

0080047d <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800480:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800484:	7e 14                	jle    80049a <getint+0x1d>
        return va_arg(*ap, long long);
  800486:	8b 45 08             	mov    0x8(%ebp),%eax
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	8d 48 08             	lea    0x8(%eax),%ecx
  80048e:	8b 55 08             	mov    0x8(%ebp),%edx
  800491:	89 0a                	mov    %ecx,(%edx)
  800493:	8b 50 04             	mov    0x4(%eax),%edx
  800496:	8b 00                	mov    (%eax),%eax
  800498:	eb 28                	jmp    8004c2 <getint+0x45>
    }
    else if (lflag) {
  80049a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80049e:	74 12                	je     8004b2 <getint+0x35>
        return va_arg(*ap, long);
  8004a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ab:	89 0a                	mov    %ecx,(%edx)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	99                   	cltd   
  8004b0:	eb 10                	jmp    8004c2 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bd:	89 0a                	mov    %ecx,(%edx)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	99                   	cltd   
    }
}
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  8004ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8004cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	ff 75 10             	pushl  0x10(%ebp)
  8004d7:	ff 75 0c             	pushl  0xc(%ebp)
  8004da:	ff 75 08             	pushl  0x8(%ebp)
  8004dd:	e8 06 00 00 00       	call   8004e8 <vprintfmt>
  8004e2:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  8004e5:	90                   	nop
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	56                   	push   %esi
  8004ec:	53                   	push   %ebx
  8004ed:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8004f0:	eb 17                	jmp    800509 <vprintfmt+0x21>
            if (ch == '\0') {
  8004f2:	85 db                	test   %ebx,%ebx
  8004f4:	0f 84 8e 03 00 00    	je     800888 <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	53                   	push   %ebx
  800501:	8b 45 08             	mov    0x8(%ebp),%eax
  800504:	ff d0                	call   *%eax
  800506:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800509:	8b 45 10             	mov    0x10(%ebp),%eax
  80050c:	8d 50 01             	lea    0x1(%eax),%edx
  80050f:	89 55 10             	mov    %edx,0x10(%ebp)
  800512:	0f b6 00             	movzbl (%eax),%eax
  800515:	0f b6 d8             	movzbl %al,%ebx
  800518:	83 fb 25             	cmp    $0x25,%ebx
  80051b:	75 d5                	jne    8004f2 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  80051d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800521:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800528:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  80052e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800535:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800538:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80053b:	8b 45 10             	mov    0x10(%ebp),%eax
  80053e:	8d 50 01             	lea    0x1(%eax),%edx
  800541:	89 55 10             	mov    %edx,0x10(%ebp)
  800544:	0f b6 00             	movzbl (%eax),%eax
  800547:	0f b6 d8             	movzbl %al,%ebx
  80054a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80054d:	83 f8 55             	cmp    $0x55,%eax
  800550:	0f 87 05 03 00 00    	ja     80085b <vprintfmt+0x373>
  800556:	8b 04 85 a8 10 80 00 	mov    0x8010a8(,%eax,4),%eax
  80055d:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  80055f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800563:	eb d6                	jmp    80053b <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800565:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800569:	eb d0                	jmp    80053b <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  80056b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800572:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800575:	89 d0                	mov    %edx,%eax
  800577:	c1 e0 02             	shl    $0x2,%eax
  80057a:	01 d0                	add    %edx,%eax
  80057c:	01 c0                	add    %eax,%eax
  80057e:	01 d8                	add    %ebx,%eax
  800580:	83 e8 30             	sub    $0x30,%eax
  800583:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800586:	8b 45 10             	mov    0x10(%ebp),%eax
  800589:	0f b6 00             	movzbl (%eax),%eax
  80058c:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  80058f:	83 fb 2f             	cmp    $0x2f,%ebx
  800592:	7e 39                	jle    8005cd <vprintfmt+0xe5>
  800594:	83 fb 39             	cmp    $0x39,%ebx
  800597:	7f 34                	jg     8005cd <vprintfmt+0xe5>
            for (precision = 0; ; ++ fmt) {
  800599:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
  80059d:	eb d3                	jmp    800572 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  8005ad:	eb 1f                	jmp    8005ce <vprintfmt+0xe6>

        case '.':
            if (width < 0)
  8005af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8005b3:	79 86                	jns    80053b <vprintfmt+0x53>
                width = 0;
  8005b5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  8005bc:	e9 7a ff ff ff       	jmp    80053b <vprintfmt+0x53>

        case '#':
            altflag = 1;
  8005c1:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  8005c8:	e9 6e ff ff ff       	jmp    80053b <vprintfmt+0x53>
            goto process_precision;
  8005cd:	90                   	nop

        process_precision:
            if (width < 0)
  8005ce:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8005d2:	0f 89 63 ff ff ff    	jns    80053b <vprintfmt+0x53>
                width = precision, precision = -1;
  8005d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005db:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8005de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  8005e5:	e9 51 ff ff ff       	jmp    80053b <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  8005ea:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  8005ee:	e9 48 ff ff ff       	jmp    80053b <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	50                   	push   %eax
  800605:	8b 45 08             	mov    0x8(%ebp),%eax
  800608:	ff d0                	call   *%eax
  80060a:	83 c4 10             	add    $0x10,%esp
            break;
  80060d:	e9 71 02 00 00       	jmp    800883 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  80061d:	85 db                	test   %ebx,%ebx
  80061f:	79 02                	jns    800623 <vprintfmt+0x13b>
                err = -err;
  800621:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800623:	83 fb 18             	cmp    $0x18,%ebx
  800626:	7f 0b                	jg     800633 <vprintfmt+0x14b>
  800628:	8b 34 9d 20 10 80 00 	mov    0x801020(,%ebx,4),%esi
  80062f:	85 f6                	test   %esi,%esi
  800631:	75 19                	jne    80064c <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
  800633:	53                   	push   %ebx
  800634:	68 95 10 80 00       	push   $0x801095
  800639:	ff 75 0c             	pushl  0xc(%ebp)
  80063c:	ff 75 08             	pushl  0x8(%ebp)
  80063f:	e8 80 fe ff ff       	call   8004c4 <printfmt>
  800644:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800647:	e9 37 02 00 00       	jmp    800883 <vprintfmt+0x39b>
                printfmt(putch, putdat, "%s", p);
  80064c:	56                   	push   %esi
  80064d:	68 9e 10 80 00       	push   $0x80109e
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	ff 75 08             	pushl  0x8(%ebp)
  800658:	e8 67 fe ff ff       	call   8004c4 <printfmt>
  80065d:	83 c4 10             	add    $0x10,%esp
            break;
  800660:	e9 1e 02 00 00       	jmp    800883 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	8b 30                	mov    (%eax),%esi
  800670:	85 f6                	test   %esi,%esi
  800672:	75 05                	jne    800679 <vprintfmt+0x191>
                p = "(null)";
  800674:	be a1 10 80 00       	mov    $0x8010a1,%esi
            }
            if (width > 0 && padc != '-') {
  800679:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80067d:	7e 76                	jle    8006f5 <vprintfmt+0x20d>
  80067f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800683:	74 70                	je     8006f5 <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800685:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	50                   	push   %eax
  80068c:	56                   	push   %esi
  80068d:	e8 b7 03 00 00       	call   800a49 <strnlen>
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	89 c2                	mov    %eax,%edx
  800697:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80069a:	29 d0                	sub    %edx,%eax
  80069c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80069f:	eb 17                	jmp    8006b8 <vprintfmt+0x1d0>
                    putch(padc, putdat);
  8006a1:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	50                   	push   %eax
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	ff d0                	call   *%eax
  8006b1:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
  8006b4:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  8006b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006bc:	7f e3                	jg     8006a1 <vprintfmt+0x1b9>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8006be:	eb 35                	jmp    8006f5 <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
  8006c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c4:	74 1c                	je     8006e2 <vprintfmt+0x1fa>
  8006c6:	83 fb 1f             	cmp    $0x1f,%ebx
  8006c9:	7e 05                	jle    8006d0 <vprintfmt+0x1e8>
  8006cb:	83 fb 7e             	cmp    $0x7e,%ebx
  8006ce:	7e 12                	jle    8006e2 <vprintfmt+0x1fa>
                    putch('?', putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	ff 75 0c             	pushl  0xc(%ebp)
  8006d6:	6a 3f                	push   $0x3f
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	ff d0                	call   *%eax
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	ff 75 0c             	pushl  0xc(%ebp)
  8006e8:	53                   	push   %ebx
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	ff d0                	call   *%eax
  8006ee:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8006f1:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  8006f5:	89 f0                	mov    %esi,%eax
  8006f7:	8d 70 01             	lea    0x1(%eax),%esi
  8006fa:	0f b6 00             	movzbl (%eax),%eax
  8006fd:	0f be d8             	movsbl %al,%ebx
  800700:	85 db                	test   %ebx,%ebx
  800702:	74 26                	je     80072a <vprintfmt+0x242>
  800704:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800708:	78 b6                	js     8006c0 <vprintfmt+0x1d8>
  80070a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80070e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800712:	79 ac                	jns    8006c0 <vprintfmt+0x1d8>
                }
            }
            for (; width > 0; width --) {
  800714:	eb 14                	jmp    80072a <vprintfmt+0x242>
                putch(' ', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	ff 75 0c             	pushl  0xc(%ebp)
  80071c:	6a 20                	push   $0x20
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	ff d0                	call   *%eax
  800723:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
  800726:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  80072a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80072e:	7f e6                	jg     800716 <vprintfmt+0x22e>
            }
            break;
  800730:	e9 4e 01 00 00       	jmp    800883 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 e0             	pushl  -0x20(%ebp)
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	e8 39 fd ff ff       	call   80047d <getint>
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80074a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  80074d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800750:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	79 23                	jns    80077a <vprintfmt+0x292>
                putch('-', putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	ff 75 0c             	pushl  0xc(%ebp)
  80075d:	6a 2d                	push   $0x2d
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	ff d0                	call   *%eax
  800764:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  800767:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076d:	f7 d8                	neg    %eax
  80076f:	83 d2 00             	adc    $0x0,%edx
  800772:	f7 da                	neg    %edx
  800774:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800777:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  80077a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800781:	e9 9f 00 00 00       	jmp    800825 <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	ff 75 e0             	pushl  -0x20(%ebp)
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	e8 99 fc ff ff       	call   80042e <getuint>
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80079b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  80079e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  8007a5:	eb 7e                	jmp    800825 <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	e8 78 fc ff ff       	call   80042e <getuint>
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  8007bf:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  8007c6:	eb 5d                	jmp    800825 <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	6a 30                	push   $0x30
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	ff d0                	call   *%eax
  8007d5:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  8007d8:	83 ec 08             	sub    $0x8,%esp
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	6a 78                	push   $0x78
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	ff d0                	call   *%eax
  8007e5:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  8007fd:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800804:	eb 1f                	jmp    800825 <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	ff 75 e0             	pushl  -0x20(%ebp)
  80080c:	8d 45 14             	lea    0x14(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	e8 19 fc ff ff       	call   80042e <getuint>
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80081b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  80081e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800825:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800829:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082c:	83 ec 04             	sub    $0x4,%esp
  80082f:	52                   	push   %edx
  800830:	ff 75 e8             	pushl  -0x18(%ebp)
  800833:	50                   	push   %eax
  800834:	ff 75 f4             	pushl  -0xc(%ebp)
  800837:	ff 75 f0             	pushl  -0x10(%ebp)
  80083a:	ff 75 0c             	pushl  0xc(%ebp)
  80083d:	ff 75 08             	pushl  0x8(%ebp)
  800840:	e8 fd fa ff ff       	call   800342 <printnum>
  800845:	83 c4 20             	add    $0x20,%esp
            break;
  800848:	eb 39                	jmp    800883 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	53                   	push   %ebx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	ff d0                	call   *%eax
  800856:	83 c4 10             	add    $0x10,%esp
            break;
  800859:	eb 28                	jmp    800883 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	6a 25                	push   $0x25
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	ff d0                	call   *%eax
  800868:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  80086b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80086f:	eb 04                	jmp    800875 <vprintfmt+0x38d>
  800871:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800875:	8b 45 10             	mov    0x10(%ebp),%eax
  800878:	83 e8 01             	sub    $0x1,%eax
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	3c 25                	cmp    $0x25,%al
  800880:	75 ef                	jne    800871 <vprintfmt+0x389>
                /* do nothing */;
            break;
  800882:	90                   	nop
    while (1) {
  800883:	e9 68 fc ff ff       	jmp    8004f0 <vprintfmt+0x8>
                return;
  800888:	90                   	nop
        }
    }
}
  800889:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80088c:	5b                   	pop    %ebx
  80088d:	5e                   	pop    %esi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
  800896:	8b 40 08             	mov    0x8(%eax),%eax
  800899:	8d 50 01             	lea    0x1(%eax),%edx
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  8008a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a5:	8b 10                	mov    (%eax),%edx
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008aa:	8b 40 04             	mov    0x4(%eax),%eax
  8008ad:	39 c2                	cmp    %eax,%edx
  8008af:	73 12                	jae    8008c3 <sprintputch+0x33>
        *b->buf ++ = ch;
  8008b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b4:	8b 00                	mov    (%eax),%eax
  8008b6:	8d 48 01             	lea    0x1(%eax),%ecx
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 0a                	mov    %ecx,(%edx)
  8008be:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c1:	88 10                	mov    %dl,(%eax)
    }
}
  8008c3:	90                   	nop
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  8008cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8008cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  8008d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d5:	50                   	push   %eax
  8008d6:	ff 75 10             	pushl  0x10(%ebp)
  8008d9:	ff 75 0c             	pushl  0xc(%ebp)
  8008dc:	ff 75 08             	pushl  0x8(%ebp)
  8008df:	e8 0b 00 00 00       	call   8008ef <vsnprintf>
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  8008ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	8d 50 ff             	lea    -0x1(%eax),%edx
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	01 d0                	add    %edx,%eax
  800906:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800909:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800910:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800914:	74 0a                	je     800920 <vsnprintf+0x31>
  800916:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091c:	39 c2                	cmp    %eax,%edx
  80091e:	76 07                	jbe    800927 <vsnprintf+0x38>
        return -E_INVAL;
  800920:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800925:	eb 20                	jmp    800947 <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800927:	ff 75 14             	pushl  0x14(%ebp)
  80092a:	ff 75 10             	pushl  0x10(%ebp)
  80092d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800930:	50                   	push   %eax
  800931:	68 90 08 80 00       	push   $0x800890
  800936:	e8 ad fb ff ff       	call   8004e8 <vprintfmt>
  80093b:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  80093e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800941:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800944:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800952:	a1 00 20 80 00       	mov    0x802000,%eax
  800957:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80095d:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800963:	6b f0 05             	imul   $0x5,%eax,%esi
  800966:	01 fe                	add    %edi,%esi
  800968:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  80096d:	f7 e7                	mul    %edi
  80096f:	01 d6                	add    %edx,%esi
  800971:	89 f2                	mov    %esi,%edx
  800973:	83 c0 0b             	add    $0xb,%eax
  800976:	83 d2 00             	adc    $0x0,%edx
  800979:	89 c7                	mov    %eax,%edi
  80097b:	83 e7 ff             	and    $0xffffffff,%edi
  80097e:	89 f9                	mov    %edi,%ecx
  800980:	0f b7 da             	movzwl %dx,%ebx
  800983:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800989:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  80098f:	a1 00 20 80 00       	mov    0x802000,%eax
  800994:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80099a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  80099e:	c1 ea 0c             	shr    $0xc,%edx
  8009a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  8009a7:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  8009ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8009ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8009c4:	74 1c                	je     8009e2 <rand+0x99>
  8009c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	f7 75 dc             	divl   -0x24(%ebp)
  8009d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8009d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	f7 75 dc             	divl   -0x24(%ebp)
  8009df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8009e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8009e8:	f7 75 dc             	divl   -0x24(%ebp)
  8009eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8009f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800a00:	83 c4 24             	add    $0x24,%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
    next = seed;
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a13:	a3 00 20 80 00       	mov    %eax,0x802000
  800a18:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800a1e:	90                   	nop
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800a27:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  800a2e:	eb 04                	jmp    800a34 <strlen+0x13>
        cnt ++;
  800a30:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8d 50 01             	lea    0x1(%eax),%edx
  800a3a:	89 55 08             	mov    %edx,0x8(%ebp)
  800a3d:	0f b6 00             	movzbl (%eax),%eax
  800a40:	84 c0                	test   %al,%al
  800a42:	75 ec                	jne    800a30 <strlen+0xf>
    }
    return cnt;
  800a44:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800a4f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800a56:	eb 04                	jmp    800a5c <strnlen+0x13>
        cnt ++;
  800a58:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  800a5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a5f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800a62:	73 10                	jae    800a74 <strnlen+0x2b>
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8d 50 01             	lea    0x1(%eax),%edx
  800a6a:	89 55 08             	mov    %edx,0x8(%ebp)
  800a6d:	0f b6 00             	movzbl (%eax),%eax
  800a70:	84 c0                	test   %al,%al
  800a72:	75 e4                	jne    800a58 <strnlen+0xf>
    }
    return cnt;
  800a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	83 ec 20             	sub    $0x20,%esp
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800a8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a93:	89 d1                	mov    %edx,%ecx
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	89 ce                	mov    %ecx,%esi
  800a99:	89 d7                	mov    %edx,%edi
  800a9b:	ac                   	lods   %ds:(%esi),%al
  800a9c:	aa                   	stos   %al,%es:(%edi)
  800a9d:	84 c0                	test   %al,%al
  800a9f:	75 fa                	jne    800a9b <strcpy+0x22>
  800aa1:	89 fa                	mov    %edi,%edx
  800aa3:	89 f1                	mov    %esi,%ecx
  800aa5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800aa8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800aab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800ab1:	83 c4 20             	add    $0x20,%esp
  800ab4:	5e                   	pop    %esi
  800ab5:	5f                   	pop    %edi
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800ac4:	eb 21                	jmp    800ae7 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  800ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac9:	0f b6 10             	movzbl (%eax),%edx
  800acc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800acf:	88 10                	mov    %dl,(%eax)
  800ad1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ad4:	0f b6 00             	movzbl (%eax),%eax
  800ad7:	84 c0                	test   %al,%al
  800ad9:	74 04                	je     800adf <strncpy+0x27>
            src ++;
  800adb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  800adf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ae3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  800ae7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aeb:	75 d9                	jne    800ac6 <strncpy+0xe>
    }
    return dst;
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	83 ec 20             	sub    $0x20,%esp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b03:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  800b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	89 ce                	mov    %ecx,%esi
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	ac                   	lods   %ds:(%esi),%al
  800b15:	ae                   	scas   %es:(%edi),%al
  800b16:	75 08                	jne    800b20 <strcmp+0x2e>
  800b18:	84 c0                	test   %al,%al
  800b1a:	75 f8                	jne    800b14 <strcmp+0x22>
  800b1c:	31 c0                	xor    %eax,%eax
  800b1e:	eb 04                	jmp    800b24 <strcmp+0x32>
  800b20:	19 c0                	sbb    %eax,%eax
  800b22:	0c 01                	or     $0x1,%al
  800b24:	89 fa                	mov    %edi,%edx
  800b26:	89 f1                	mov    %esi,%ecx
  800b28:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800b2e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  800b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  800b34:	83 c4 20             	add    $0x20,%esp
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800b3e:	eb 0c                	jmp    800b4c <strncmp+0x11>
        n --, s1 ++, s2 ++;
  800b40:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b48:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800b4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b50:	74 1a                	je     800b6c <strncmp+0x31>
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	0f b6 00             	movzbl (%eax),%eax
  800b58:	84 c0                	test   %al,%al
  800b5a:	74 10                	je     800b6c <strncmp+0x31>
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	0f b6 10             	movzbl (%eax),%edx
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	0f b6 00             	movzbl (%eax),%eax
  800b68:	38 c2                	cmp    %al,%dl
  800b6a:	74 d4                	je     800b40 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800b6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b70:	74 18                	je     800b8a <strncmp+0x4f>
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	0f b6 00             	movzbl (%eax),%eax
  800b78:	0f b6 d0             	movzbl %al,%edx
  800b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7e:	0f b6 00             	movzbl (%eax),%eax
  800b81:	0f b6 c8             	movzbl %al,%ecx
  800b84:	89 d0                	mov    %edx,%eax
  800b86:	29 c8                	sub    %ecx,%eax
  800b88:	eb 05                	jmp    800b8f <strncmp+0x54>
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 04             	sub    $0x4,%esp
  800b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800b9d:	eb 14                	jmp    800bb3 <strchr+0x22>
        if (*s == c) {
  800b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba2:	0f b6 00             	movzbl (%eax),%eax
  800ba5:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800ba8:	75 05                	jne    800baf <strchr+0x1e>
            return (char *)s;
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	eb 13                	jmp    800bc2 <strchr+0x31>
        }
        s ++;
  800baf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  800bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb6:	0f b6 00             	movzbl (%eax),%eax
  800bb9:	84 c0                	test   %al,%al
  800bbb:	75 e2                	jne    800b9f <strchr+0xe>
    }
    return NULL;
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 04             	sub    $0x4,%esp
  800bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcd:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800bd0:	eb 0f                	jmp    800be1 <strfind+0x1d>
        if (*s == c) {
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	0f b6 00             	movzbl (%eax),%eax
  800bd8:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800bdb:	74 10                	je     800bed <strfind+0x29>
            break;
        }
        s ++;
  800bdd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  800be1:	8b 45 08             	mov    0x8(%ebp),%eax
  800be4:	0f b6 00             	movzbl (%eax),%eax
  800be7:	84 c0                	test   %al,%al
  800be9:	75 e7                	jne    800bd2 <strfind+0xe>
  800beb:	eb 01                	jmp    800bee <strfind+0x2a>
            break;
  800bed:	90                   	nop
    }
    return (char *)s;
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800bf9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800c00:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800c07:	eb 04                	jmp    800c0d <strtol+0x1a>
        s ++;
  800c09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	0f b6 00             	movzbl (%eax),%eax
  800c13:	3c 20                	cmp    $0x20,%al
  800c15:	74 f2                	je     800c09 <strtol+0x16>
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	0f b6 00             	movzbl (%eax),%eax
  800c1d:	3c 09                	cmp    $0x9,%al
  800c1f:	74 e8                	je     800c09 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	0f b6 00             	movzbl (%eax),%eax
  800c27:	3c 2b                	cmp    $0x2b,%al
  800c29:	75 06                	jne    800c31 <strtol+0x3e>
        s ++;
  800c2b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c2f:	eb 15                	jmp    800c46 <strtol+0x53>
    }
    else if (*s == '-') {
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	0f b6 00             	movzbl (%eax),%eax
  800c37:	3c 2d                	cmp    $0x2d,%al
  800c39:	75 0b                	jne    800c46 <strtol+0x53>
        s ++, neg = 1;
  800c3b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c3f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  800c46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c4a:	74 06                	je     800c52 <strtol+0x5f>
  800c4c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c50:	75 24                	jne    800c76 <strtol+0x83>
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	0f b6 00             	movzbl (%eax),%eax
  800c58:	3c 30                	cmp    $0x30,%al
  800c5a:	75 1a                	jne    800c76 <strtol+0x83>
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	83 c0 01             	add    $0x1,%eax
  800c62:	0f b6 00             	movzbl (%eax),%eax
  800c65:	3c 78                	cmp    $0x78,%al
  800c67:	75 0d                	jne    800c76 <strtol+0x83>
        s += 2, base = 16;
  800c69:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800c6d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c74:	eb 2a                	jmp    800ca0 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  800c76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c7a:	75 17                	jne    800c93 <strtol+0xa0>
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	0f b6 00             	movzbl (%eax),%eax
  800c82:	3c 30                	cmp    $0x30,%al
  800c84:	75 0d                	jne    800c93 <strtol+0xa0>
        s ++, base = 8;
  800c86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c8a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c91:	eb 0d                	jmp    800ca0 <strtol+0xad>
    }
    else if (base == 0) {
  800c93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c97:	75 07                	jne    800ca0 <strtol+0xad>
        base = 10;
  800c99:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca3:	0f b6 00             	movzbl (%eax),%eax
  800ca6:	3c 2f                	cmp    $0x2f,%al
  800ca8:	7e 1b                	jle    800cc5 <strtol+0xd2>
  800caa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cad:	0f b6 00             	movzbl (%eax),%eax
  800cb0:	3c 39                	cmp    $0x39,%al
  800cb2:	7f 11                	jg     800cc5 <strtol+0xd2>
            dig = *s - '0';
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	0f b6 00             	movzbl (%eax),%eax
  800cba:	0f be c0             	movsbl %al,%eax
  800cbd:	83 e8 30             	sub    $0x30,%eax
  800cc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cc3:	eb 48                	jmp    800d0d <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	0f b6 00             	movzbl (%eax),%eax
  800ccb:	3c 60                	cmp    $0x60,%al
  800ccd:	7e 1b                	jle    800cea <strtol+0xf7>
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	0f b6 00             	movzbl (%eax),%eax
  800cd5:	3c 7a                	cmp    $0x7a,%al
  800cd7:	7f 11                	jg     800cea <strtol+0xf7>
            dig = *s - 'a' + 10;
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	0f b6 00             	movzbl (%eax),%eax
  800cdf:	0f be c0             	movsbl %al,%eax
  800ce2:	83 e8 57             	sub    $0x57,%eax
  800ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ce8:	eb 23                	jmp    800d0d <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	0f b6 00             	movzbl (%eax),%eax
  800cf0:	3c 40                	cmp    $0x40,%al
  800cf2:	7e 3c                	jle    800d30 <strtol+0x13d>
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	0f b6 00             	movzbl (%eax),%eax
  800cfa:	3c 5a                	cmp    $0x5a,%al
  800cfc:	7f 32                	jg     800d30 <strtol+0x13d>
            dig = *s - 'A' + 10;
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	0f b6 00             	movzbl (%eax),%eax
  800d04:	0f be c0             	movsbl %al,%eax
  800d07:	83 e8 37             	sub    $0x37,%eax
  800d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d10:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d13:	7d 1a                	jge    800d2f <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
  800d15:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d19:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d1c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d20:	89 c2                	mov    %eax,%edx
  800d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d25:	01 d0                	add    %edx,%eax
  800d27:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  800d2a:	e9 71 ff ff ff       	jmp    800ca0 <strtol+0xad>
            break;
  800d2f:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  800d30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d34:	74 08                	je     800d3e <strtol+0x14b>
        *endptr = (char *) s;
  800d36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  800d3e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d42:	74 07                	je     800d4b <strtol+0x158>
  800d44:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d47:	f7 d8                	neg    %eax
  800d49:	eb 03                	jmp    800d4e <strtol+0x15b>
  800d4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	83 ec 24             	sub    $0x24,%esp
  800d57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800d5d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800d67:	88 45 f7             	mov    %al,-0x9(%ebp)
  800d6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800d70:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800d73:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800d77:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	f3 aa                	rep stos %al,%es:(%edi)
  800d7e:	89 fa                	mov    %edi,%edx
  800d80:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800d83:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800d86:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800d89:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    

00800d8e <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 30             	sub    $0x30,%esp
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800da3:	8b 45 10             	mov    0x10(%ebp),%eax
  800da6:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dac:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800daf:	73 42                	jae    800df3 <memmove+0x65>
  800db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800db7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800dc0:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800dc6:	c1 e8 02             	shr    $0x2,%eax
  800dc9:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800dcb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800dce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dd1:	89 d7                	mov    %edx,%edi
  800dd3:	89 c6                	mov    %eax,%esi
  800dd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dd7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800dda:	83 e1 03             	and    $0x3,%ecx
  800ddd:	74 02                	je     800de1 <memmove+0x53>
  800ddf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800de1:	89 f0                	mov    %esi,%eax
  800de3:	89 fa                	mov    %edi,%edx
  800de5:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800de8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800deb:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  800dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  800df1:	eb 36                	jmp    800e29 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800df3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800df6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800df9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dfc:	01 c2                	add    %eax,%edx
  800dfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e01:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e07:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  800e0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e0d:	89 c1                	mov    %eax,%ecx
  800e0f:	89 d8                	mov    %ebx,%eax
  800e11:	89 d6                	mov    %edx,%esi
  800e13:	89 c7                	mov    %eax,%edi
  800e15:	fd                   	std    
  800e16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800e18:	fc                   	cld    
  800e19:	89 f8                	mov    %edi,%eax
  800e1b:	89 f2                	mov    %esi,%edx
  800e1d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800e20:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800e23:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  800e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800e29:	83 c4 30             	add    $0x30,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	83 ec 20             	sub    $0x20,%esp
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e45:	8b 45 10             	mov    0x10(%ebp),%eax
  800e48:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e4e:	c1 e8 02             	shr    $0x2,%eax
  800e51:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800e53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e59:	89 d7                	mov    %edx,%edi
  800e5b:	89 c6                	mov    %eax,%esi
  800e5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e5f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e62:	83 e1 03             	and    $0x3,%ecx
  800e65:	74 02                	je     800e69 <memcpy+0x38>
  800e67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800e69:	89 f0                	mov    %esi,%eax
  800e6b:	89 fa                	mov    %edi,%edx
  800e6d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800e70:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e73:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  800e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800e79:	83 c4 20             	add    $0x20,%esp
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  800e92:	eb 30                	jmp    800ec4 <memcmp+0x44>
        if (*s1 != *s2) {
  800e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e97:	0f b6 10             	movzbl (%eax),%edx
  800e9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e9d:	0f b6 00             	movzbl (%eax),%eax
  800ea0:	38 c2                	cmp    %al,%dl
  800ea2:	74 18                	je     800ebc <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800ea4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ea7:	0f b6 00             	movzbl (%eax),%eax
  800eaa:	0f b6 d0             	movzbl %al,%edx
  800ead:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eb0:	0f b6 00             	movzbl (%eax),%eax
  800eb3:	0f b6 c8             	movzbl %al,%ecx
  800eb6:	89 d0                	mov    %edx,%eax
  800eb8:	29 c8                	sub    %ecx,%eax
  800eba:	eb 1a                	jmp    800ed6 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  800ebc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ec0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  800ec4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800eca:	89 55 10             	mov    %edx,0x10(%ebp)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	75 c3                	jne    800e94 <memcmp+0x14>
    }
    return 0;
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800ed8:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  800edc:	83 e4 f0             	and    $0xfffffff0,%esp
  800edf:	ff 71 fc             	pushl  -0x4(%ecx)
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	51                   	push   %ecx
  800ee6:	83 ec 04             	sub    $0x4,%esp
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800ee9:	b8 00 00 c0 fa       	mov    $0xfac00000,%eax
  800eee:	8b 00                	mov    (%eax),%eax
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	50                   	push   %eax
  800ef4:	68 00 12 80 00       	push   $0x801200
  800ef9:	e8 13 f2 ff ff       	call   800111 <cprintf>
  800efe:	83 c4 10             	add    $0x10,%esp
    panic("FAIL: T.T\n");
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	68 1e 12 80 00       	push   $0x80121e
  800f09:	6a 07                	push   $0x7
  800f0b:	68 29 12 80 00       	push   $0x801229
  800f10:	e8 1a f1 ff ff       	call   80002f <__panic>
