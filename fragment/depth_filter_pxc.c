#include <stdio.h>
#include <string.h>

void main(int argc, char *argv[])
{
    FILE *fbed;
    char row_string[1000] = {0};
    char bed_string[4];
    fbed = fopen("/opt/seqtools/bed/SeqCap_EZ_Exome_v3_capture.bed", "r");
    if (fbed == NULL)
    {
        printf("Error : Can not open file %s\n");
        return 1;
    }

    while(!feof(fbed))
    {
        memset(row_string, 0, sizeof(row_string));
        fgets(row_string, sizeof(row_string) - 1, fbed);
        const char* val1 = strchr(row_string, '\t') + 1;
        printf("%s", val1);
    }

    fclose(fbed);
}