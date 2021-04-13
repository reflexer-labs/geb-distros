#!/bin/bash
set -E

if [ "$#" -ne 3 ]; then
    echo "Usage: ./run_incentives_query_with_owner_mapping.sh <query_file> <exclusions file> <output_file>"
    exit
fi

python3 -m venv venv
source venv/bin/activate
pip install -r python/requirements.txt |grep -v 'already satisfied'
python python/incentives_query_with_owner_mapping.py $1 $2 $3
deactivate
