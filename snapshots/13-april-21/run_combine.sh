#!/bin/bash
set -E

if [ "$#" -ne 1 ]; then
    echo "Usage: ./run_combine.sh <folder with queries to combine>"
    exit
fi

python3 -m venv venv
source venv/bin/activate
pip install -r python/requirements.txt |grep -v 'already satisfied'
python python/combine_all.py $1
deactivate
