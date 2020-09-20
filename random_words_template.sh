#!/bin/bash
#############################
#
# Insert random words into template file for test data
#
#   Charles Shapiro 20 Sep 2020
#
#    This file is part of random_words_template.
#    random_words_template is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    random_words_template is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with random_words_template.  If not, see <http://www.gnu.org/licenses/>.

#
#############################

#
# Find a random word in words; return it in ${RANDOMWORD}
#
getrandomword () {
    WORDFILE=$2
    WORDLEN=$(wc -l ${WORDFILE} | awk '{print $1}')
    RANDWORDIDX=$((${RANDOM} % ${WORDLEN}))
    RANDWORD=$(sed "${RANDWORDIDX}q;d" ${WORDFILE})
    if [ ${1:-"nocap"} = 'cap' ]
    then
	RANDWORD="$(tr [:lower:] [:upper:] <<< ${RANDWORD:0:1})${RANDWORD:1}"
    else
	RANDWORD="$(tr [:upper:] [:lower:] <<< ${RANDWORD:0:1})${RANDWORD:1}"
    fi
    
}

usage () {
    echo Usage: $0 -i infile -o outfile 
    cat <<EOU
   Replace %{template} words with random words in infile to
   outfile. If outfile is not specified then I will write to
   stdout. infile defaults to "o_intemplate.txt". If your %{Template}
   name has an Initial Cap, the replacement word will also.  So 
   "%{one} in %{Two} with %{one}" in infile becomes 
   "cryptozoic in Israels with cryptozoic" 
   on one run, but perhaps "clinic in Duteous with clinic" on
   the next.
EOU
    }
#
# Main Line
#
OPTSTR="i:o:c"

CAPWORDS="nocap"

while getopts ${OPTSTR} arg
do
    case ${arg} in
	i) TEMPLATE=${OPTARG} ;;	
	o) OUTFILE=${OPTARG} ;;
	c) CAPWORDS="cap" ;;
	h) usage $0 ; exit 1 ;;
	?) echo Invalid Flag: ${arg} ; usage $0 ; exit 1 ;;
    esac
done


if [ ${TEMPLATE:-nothing} = "nothing" ]
then
    TEMPLATE="o_intemplate.txt"
fi

if [ ! -f ${TEMPLATE} ]
then
    echo ${TEMPLATE} not found.
    usage $0
    exit 1
fi

if [ "${OUTFILE}" != "" ]
then
    if [ -f ${OUTFILE} ]
    then
	
	YN="/"
	while [ $YN = "/" ]
	do	
	    read -p " ${OUTFILE} already exists. Replace? " YN
	    if echo ${YN} | grep "^[Yy]"
	    then
		break
	    elif echo ${YN} | grep "^[Nn]"
	    then
		echo Phew\!
		exit 2
	    else
		YN="/"
	    fi
	done
    fi
fi

REPLACESTRS=$( sed -E -e  's/(%\{[^\}]+\})/\n\1\n/g' < ${TEMPLATE} | grep "^%" | sort -u)

WORDFILE=/tmp/$0_${RANDOM}
grep -v \' /usr/share/dict/words > ${WORDFILE}
for kk in ${REPLACESTRS}
do
    if echo $kk | tr -d '%{}' | grep "^[[:upper:]]" > /dev/null
    then
	CAPWORDS="cap"
    else
	CAPWORDS="nocap"
    fi    
    getrandomword ${CAPWORDS} ${WORDFILE}
    P=${RANDWORD}
    SEDCMD="${SEDCMD} -e s/$kk/$P/g"
done

rm ${WORDFILE}

# set -x
if [ "${OUTFILE}" != "" ]
then
    sed ${SEDCMD} < ${TEMPLATE} > ${OUTFILE}
else
    sed ${SEDCMD} < ${TEMPLATE}
fi

