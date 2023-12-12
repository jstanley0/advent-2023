// ?#?#?#?#?#?#?#? 1,3,1,6

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void die(const char *message) {
    printf("%s\n", message);
    exit(1);
}

int bitcount(size_t val) {
    int n = 0;
    while(val) {
        if (val & 1) ++n;
        val >>= 1;
    }
    return n;
}

int match_extent(const char **p, int n)
{
    // printf(" match_extent(%s, %d)\n", *p, n);

    while(**p == '.') ++(*p);
    while(n-- > 0) {
        if (*(*p)++ != '#')
            return 0;
    }
    return **p != '#';
}

int check_pattern(const char *pattern, int *extents, int nx)
{
    const char *c = pattern;
    for(int n = 0; n < nx; ++n) {
        if (!match_extent(&c, extents[n])) {
            return 0;
        }
    }
    return 1;
}

int main(int argc, char **argv)
{
    long long total = 0;
    char line[240];
    while(fgets(line, sizeof(line), stdin)) {
        printf("%s", line);

        char *lp = line;
        char *pattern = strsep(&lp, " ");

        int extents[32];
        int xcount = 0;
        size_t nx = 0;
        char *tok;
        while ((tok = strsep(&lp, ","))) {
            int ex = atoi(tok);
            xcount += ex;
            extents[nx++] = ex;
            if (nx == 32) die("too many extents");
        }

        char *qmarks[64];
        int hcount = 0;
        size_t nq = 0;
        char *pp = pattern;
        while(*pp) {
          if (*pp == '?') {
            qmarks[nq++] = pp;
            if (nq == 64) die("too many question marks");
          } else if (*pp == '#') {
            ++hcount;
          }
          ++pp;
        }

        int count = 0;
        for(size_t i = 0, m = 1ULL << nq; i < m; ++i) {
            if (bitcount(i) != xcount - hcount)
                continue;
            for(int j = i, bit = 0; bit < nq; ++bit) {
                *qmarks[bit] = (j & 1) ? '#' : '.';
                j >>= 1;
            }
            //printf("checking pattern: %s\n", pattern);
            if (check_pattern(pattern, extents, nx))
                ++count;
        }
        printf("> %d\n", count);
        total += count;
    }
    printf("%lld\n", total);
}
