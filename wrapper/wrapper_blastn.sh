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


if [ -n "${subject}" -o -n "${subject_loc}"] && [ -n "${db}" -o -n "${gilist}" -o -n "${seqidlist}" -o -n "${negative_gilist}" -o -n "${db_soft_mask}" -o -n "${db_hard_mask}" ]
  then
    >&2 echo "subject is incompatible with: db, gilist, seqidlist, negative_gilist, db_soft_mask, db_hard_mask "
    debug
    exit 1;
fi
if [ -n "${num_descriptions}" -o -n "${num_alignments}" ] && [ -n "${max_target_seqs}" ]
  then
    >&2 echo "num_descriptions and num_alignments are incompatible with max_target_seqs"
    debug
    exit 1;
fi
if [ -n "${gilist}" ] && [ -n "${negative_gilist}" -o -n "${seqidlist}" ]
  then
    >&2 echo "gilist is incompatible with negative_gilist and seqidlist"
    debug
    exit 1;
fi
if [ -n "${seqidlist}" ] && [ -n "${negative_gilist}" ]
  then
    >&2 echo "seqidlist and negative_gilist are incompatible"
    debug
    exit 1;
fi
if [ -n "${db_soft_mask}" ] && [ -n "${db_hard_mask}" ]
  then
    >&2 echo "db_soft_mask and db_hard_mask are incompatible"
    debug
    exit 1;
fi
if [ -n "${culling_limit}" ] && [ -n "${best_hit_overhang}" -o -n "${best_hit_score_edge}" ]
  then
    >&2 echo "culling_limit is incompatible with best_hit_overhang and best_hit_score_edge"
    debug
    exit 1;
fi
if [ -n "${template_type}" -a -z "${template_length}" ] || [ -n "${template_length}" -a -z "${template_type}" ]
  then
    >&2 echo "template_type and template_length are mutually required"
    debug
    exit 1;
fi


CMDLINEARG=""
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
CMDLINEARG+="-query ${QUERYU} -out output "
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
