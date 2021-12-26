.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	# just like the preparation before the execution of int main(arg)
	# and save the return value of main on stack (by `return 0;` statement)	
    pushl %edx              # push arg
    call *%ebx              # call fn

    pushl %eax              # save the return value of fn(arg)
    call do_exit            # call do_exit to terminate current thread

