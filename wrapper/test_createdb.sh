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

try "mask_id requires mask_data"
#assert "`r_overlap=true a_overlap= ../wrapper_coverage.sh`" ""
assert_fail "`mask_id='list of strings' ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "mask_id requires mask_data file(s) and is incompatible with gi_mask."

try "mask_id incompatible with gi_mask"
assert_fail "`mask_id='list of strings' gi_mask='-gi_mask ' ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "mask_id requires mask_data file(s) and is incompatible with gi_mask."

try "mask_desc requires mask_id"
assert_fail "`mask_desc='list of strings' ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "mask_desc requires mask_id."

try "gi_mask requires parse_seqids for FASTA"
assert_fail "`gi_mask='-gi_mask ' input_type='-input_type fasta' ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "gi_mask requires parse_seqids."

try "gi_mask doesn't require parse_seqids if not FASTA"
#placeholder

try "gi_mask_name requires gi_mask"
assert_fail "`gi_mask_name='list of strings' ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "gi_mask_name requires mask_data and gi_mask."

try "gi_mask_name requires mask_data"
assert_fail "`gi_mask_name='list of strings' ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "gi_mask_name requires mask_data and gi_mask."

try "taxid_map incompatible with taxid"
assert_fail "`taxid_map=filename taxid=id ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "taxid_map is incompatible with taxid."

try "taxid_map requires parse_seqids for FASTA"
assert_fail "`taxid_map=defined_file input_type='-input_type fasta' ../wrapper_create_blast_db.sh 2>&1 >/dev/null`" "taxid_map requires parse_seqids."

try "taxid_map doesn't require parse_seqids if input is not fasta"
#placeholder

echo; echo "PASS: $tests_run tests run"
