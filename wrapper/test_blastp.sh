#!/bin/bash

#adapted from http://eradman.com/posts/ut-shell-scripts.html

typeset -i tests_run=0

function try { this="$1"; }

trap 'printf "$0: exit code $? on line $LINENO\nFAIL: $this\n"; exit 1' ERR

#check returned value is what is expected
function assert {
        let tests_run+=1
        [ "$1" = "$2" ] && { echo -n "."; return; }
        printf "\nFAIL: $this\n'$1' != '$2'\n"; exit 1
}

#check the script fails as expected
function assert_fail {
        let tests_run+=1
        [ "${1//$2}" != "${1}" ] && { echo -n "."; return; }
        printf "\nFAIL: $this\n '$1' exit code = 0\n"; exit 1
}

#check we are in an empty directory to avoid deleting files
if [ "`ls`" != "" ]
  then
    echo "ERROR: Run this script in an empty directory!!!!!"
    exit 1;
fi

try "subject mutually exclusive with db"
#assert "`r_overlap=true a_overlap= ../wrapper_coverage.sh`" ""
assert_fail "`subject=defined_file blast_db=given_database ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db,"

try "subject mutually exclusive with gilist"
assert_fail "`subject=defined_file gilist=restrictto ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist,"

try "subject mutually exclusive with seqidlist"
assert_fail "`subject=defined_file seqidlist='list of ids' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist,"

try "subject mutually exclusive with negative_gilist"
assert_fail "`subject=defined_file negative_gilist='list of ids' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist, negative_gilist,"

try "subject mutually exclusive with db_soft_mask"
assert_fail "`subject=defined_file db_soft_mask='alg id' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist, negative_gilist, db_soft_mask,"

try "subject mutually exclusive with db_hard_mask"
assert_fail "`subject=defined_file db_hard_mask='alg id' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist, negative_gilist, db_soft_mask, db_hard_mask"

try "subject_loc mutually exclusive with db"
assert_fail "`subject_loc=defined_file blast_db=given_database ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db,"

try "subject_loc mutually exclusive with gilist"
assert_fail "`subject_loc=defined_file gilist=restrictto ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist,"

try "subject_loc mutually exclusive with seqidlist"
assert_fail "`subject_loc=defined_file seqidlist='list of ids' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist,"

try "subject_loc mutually exclusive with negative_gilist"
assert_fail "`subject_loc=defined_file negative_gilist='list of ids' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist, negative_gilist,"

try "subject_loc mutually exclusive with db_soft_mask"
assert_fail "`subject_loc=defined_file db_soft_mask='alg id' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist, negative_gilist, db_soft_mask,"

try "subject_loc mutually exclusive with db_hard_mask"
assert_fail "`subject_loc=defined_file db_hard_mask='alg id' ../wrapper_blastp.sh 2>&1 >/dev/null`" "subject is incompatible with: db, gilist, seqidlist, negative_gilist, db_soft_mask, db_hard_mask"

try "num_descriptions mutually exclusive with max_target_seqs"
assert_fail "`num_descriptions=500 max_target_seqs=500 ../wrapper_blastp.sh 2>&1 >/dev/null`" "num_descriptions and num_alignments are incompatible with max_target_seqs"

try "num_alignments mutually exclusive with max_target_seqs"
assert_fail "`num_alignments=250 max_target_seqs=500 ../wrapper_blastp.sh 2>&1 >/dev/null`" "num_descriptions and num_alignments are incompatible with max_target_seqs"

try "gilist mutually exclusive with negative_gilist"
assert_fail "`gilist='list of ids' negative_gilist='another list of ids' ../wrapper_blastp.sh 2>&1 >/dev/null`" "gilist is incompatible with negative_gilist"

try "gilist mutually exclusive with seqidlist"
assert_fail "`gilist='list of ids' seqidlist='another list of ids' ../wrapper_blastp.sh 2>&1 >/dev/null`" "gilist is incompatible with negative_gilist and seqidlist"

try "seqidlist mutually exclusive with negative_gilist"
assert_fail "`seqidlist='list of ids' negative_gilist='another list of ids' ../wrapper_blastp.sh 2>&1 >/dev/null`" "seqidlist and negative_gilist are incompatible"

try "db_soft_mask mutually exclusive with db_hard_mask"
assert_fail "`db_soft_mask='filtering string' db_hard_mask='another filtering here' ../wrapper_blastp.sh 2>&1 >/dev/null`" "db_soft_mask and db_hard_mask are incompatible"

try "culling_limit mutually exclusive with best_hit_overhang"
assert_fail "`culling_limit=10 best_hit_overhang=0.1 ../wrapper_blastp.sh 2>&1 >/dev/null`" "culling_limit is incompatible with best_hit_overhang"

try "culling_limit mutually exclusive with best_hit_score_edge"
assert_fail "`culling_limit=10 best_hit_score_edge=0.1 ../wrapper_blastp.sh 2>&1 >/dev/null`" "culling_limit is incompatible with best_hit_overhang and best_hit_score_edge"

echo; echo "PASS: $tests_run tests run"
