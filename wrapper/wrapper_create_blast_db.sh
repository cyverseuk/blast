#!/bin/bash

function debug {
  echo "creating debugging directory"
mkdir .debug
for word in ${rmthis}
  do
    if [[ "${word}" == *.sh ]] || [[ "${word}" == lib ]]
      then
        mv "${word}" .debug;
      fi
  done
}

rmthis=`ls`
echo ${rmthis}

ARGSU=" ${dbtype} ${input_type} ${title} ${parse_seqids} ${hash_index} ${mask_id} ${mask_desc} ${gi_mask} ${gi_mask_name} ${out} ${max_file_sz} ${taxid} "
INPUTFILEU="${input_file}"
MASKDATAU=`echo ${mask_data} | sed -e 's/ /, /g'`
TAXIDMAPU="${taxid_map}"
INPUTSU="${INPUTFILEU}, ${MASKDATAU}, ${TAXIDMAPU}"
echo "Input file is " "${INPUTFILEU}"
echo "Mask data file(s) is/are " "${MASKDATAU}"
echo "File mapping seq IDs to taxonomy IDs is " "${TAXIDMAPU}"
echo "arguments are " "${ARGSU}"
echo "inputs are " "${INPUTSU}"


#checking for mutually inclusive/exclusive options
if [ -n "${mask_id}" ] && [ -z "${mask_data}" -o -n "${gi_mask}" ]
  then
    >&2 echo "mask_id requires mask_data file(s) and is incompatible with gi_mask. "
    debug
    exit 1;
fi
if [ -n "${mask_desc}" -a -z "${mask_id}" ]
  then
    >&2 echo "mask_desc requires mask_id."
    debug
    exit 1;
fi
if [ -n "${gi_mask}" ] && [ "${input_type}" = "-input_type fasta" -a -z "${parse_seqids}" ]
  then
    >&2 echo "gi_mask requires parse_seqids."
    debug
    exit 1;
fi
if [ -n "${gi_mask_name}" ] && [ -z "${gi_mask}" -o -z "${mask_data}" ]
  then
    >&2 echo "gi_mask_name requires mask_data and gi_mask."
    debug
    exit 1;
fi
if [ -n "${taxid_map}" ]
  then
    if [ -n "${taxid}" ]
      then
        >&2 echo "taxid_map is incompatible with taxid."
        debug
        exit 1;
    fi
    if [ "${input_type}" = "-input_type fasta" -a -z "${parse_seqids}" ]
      then
        >&2 echo "taxid_map requires parse_seqids."
        debug
        exit 1;
    fi
fi

CMDLINEARG=""
CMDLINEARG+="makeblastdb ${ARGSU} -in ${INPUTFILEU} "
if [ -n "${MASKDATAU}" ]
  then
    CMDLINEARG+="-mask_data ${MASKDATAU} "
fi
if [ -n "${TAXIDMAPU}" ]
  then
    CMDLINEARG+="-taxid_map ${TAXIDMAPU} "
fi

echo ${CMDLINEARG};
chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/blast:v2.2.31 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
#echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/apps/create_blast_db/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit -batch-name ${PWD##*/} lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0
