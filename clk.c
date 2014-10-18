#include <time.h>
#include <stdio.h>

long clockgettime () {
  struct timespec time1;
  clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);
  return time1.tv_nsec;
}
