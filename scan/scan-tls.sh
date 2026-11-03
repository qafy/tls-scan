#!/bin/bash

set -e

BASEDIR=${BASEDIR:-"/rpool/scans/tls-scans"}

DATEPATH="$(date '+%Y')/$(date '+%m')/$(date '+%Y-%m-%d-%H%M')"
OUTPUTDIR="${BASEDIR}/${DATEPATH}"

SCRIPTDIR=$(cd "$(dirname "$0")" && pwd -P)
CONFIGDIR="${SCRIPTDIR}/../config"
CHDIR="${CONFIGDIR}/client-hellos"

INPUT=${1:-"${CONFIGDIR}/input.csv"}

mkdir -p ${OUTPUTDIR}

echo "scanning targets in ${INPUT}"

# Cross product between all client hellos and the targets, shuffled to reduce bursts on target servers
SCANINPUT=${OUTPUTDIR}/input-chs.csv
${SCRIPTDIR}/goscanner create-ch-input --ch-dir ${CHDIR} --input ${INPUT} | sort -R > ${SCANINPUT}

echo "input file: ${INPUT}" >> ${OUTPUTDIR}/metadata
echo "scan input file: ${SCANINPUT}" >> ${OUTPUTDIR}/metadata
echo "client hellos: $(ls ${CHDIR} | tr '\n' ' ')" >> ${OUTPUTDIR}/metadata
echo "goscanner: $(${SCRIPTDIR}/goscanner --version 2>&1 | head -n1)" >> ${OUTPUTDIR}/metadata

echo "starting scan"
# goscanner refuses to write into an existing directory
${SCRIPTDIR}/goscanner -C ${CONFIGDIR}/tls-scan.conf --client-hello-dir ${CHDIR} -i ${SCANINPUT} -o ${OUTPUTDIR}/results &> ${OUTPUTDIR}/scan.log

echo "finished scanning"

find ${OUTPUTDIR} -type f -size +1M -print0 | xargs -0 -P 4 -L 10 ${SCRIPTDIR}/zstd-rm -9

echo "finished compressing"
