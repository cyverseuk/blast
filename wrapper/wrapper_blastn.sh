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

ARGSU=" ${query_loc} ${strand} ${task} ${evalue} ${word_size} ${gapopen} ${gapextend} ${penalty} ${reward} ${use_index} ${index_name} ${subject_loc} ${outfmt} ${show_gis} ${num_descriptions} ${num_alignments} ${line_length} ${html} ${dust} ${filtering_db} ${window_masker_taxid} ${soft_masking} ${lcase_masking} ${gilist} ${seqidlist} ${negative_gilist} ${db_soft_mask} ${db_hard_mask} ${perc_identity} ${qcov_hsp_perc} ${max_hsps} ${culling_limit} ${best_hit_overhang} ${best_hit_score_edge} ${max_target_seqs}  ${template_type} ${template_length} ${xdrop_ungap} ${xdrop_gap} ${xdrop_gap_final} ${min_raw_gapped_score} ${ungapped} ${window_size} ${off_diagonal_range} ${parse_deflines} "
QUERYU="${query}"
BLASTDBU="${blast_db}"
SUBJECTU="${subject}"
SEARCHU="${import_search_strategy}"
INPUTSU="${QUERYU}, ${BLASTDBU}, ${SUBJECTU}, ${SEARCHU}"
echo "query file is " "${QUERYU}"
echo "BLAST database is " "${BLASTDBU}"
echo "Subject file is " "${SUBJECTU}"
echo "Search strategy is " "${SEARCHU}"
echo "arguments are " "${ARGSU}"
echo "inputs are " "${INPUTSU}"


if [ -n "${r_overlap}" ]
  then
    if [ -z "${a_overlap}" ]
      then
        >&2 echo "-r must be used with -f"
        debug
        exit 1;
    fi
fi

if [ -n "${e_overlap}" ]
  then
    if [ -z "${a_overlap}" ]
      then
        >&2 echo "-r must be used with -f"
        debug
        exit 1;
    fi
fi

CMDLINEARG=""
######add check for mutually exclusive inputs and parameters here and exit in case of errors
CMDLINEARG+="blastn ${ARGSU} "
if [ -n "${BLASTDBU}" ]
  then
    CMDLINEARG+="-db ${BLASTDBU} "
fi
if [ -n "${SUBJECTU}" ]
  then
    CMDLINEARG+="-subject ${SUBJECTU} "
fi
if [ -n "${SEARCHU}" ]
  then
    CMDLINEARG+="-import_search_strategy ${SEARCHU} "
CMDLINEARG+="-query ${QUERYU} "
echo ${CMDLINEARG};
chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/blast:v2.2.31 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
#echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/apps/blastn/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit -batch-name ${PWD##*/} lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0
