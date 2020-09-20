# random_words_template

Shell script to replace words in a template file with random words


Usage: ./random_words_template.sh -i infile -o outfile
   Replace %{template} words with random words in infile to
   outfile. If outfile is not specified then I will write to
   stdout. infile defaults to "o_intemplate.txt". If your %{Template}
   name has an Initial Cap, the replacement word will also.  So 
   "%{one} in %{Two} with %{one}" in infile becomes 
   "cryptozoic in Israels with cryptozoic" 
   on one run, but perhaps "clinic in Duteous with clinic" on
   the next.

# random_words_template.sh

The shell script

# o_intemplate.txt

A sample template file




