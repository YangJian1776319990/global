$(common-objpfx)misc/truncate64.os: \
 ../sysdeps/unix/sysv/linux/wordsize-64/truncate64.c \
 ../include/stdc-predef.h ../include/libc-symbols.h \
 $(common-objpfx)config.h ../sysdeps/generic/symbol-hacks.h

../include/stdc-predef.h:

../include/libc-symbols.h:

$(common-objpfx)config.h:

../sysdeps/generic/symbol-hacks.h:
