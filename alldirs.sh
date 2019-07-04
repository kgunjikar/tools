#!/bin/bash
for D in ./*; do
        if [ -d "$D" ]; then
                cd "$D"
                $1
                cd ..
        fi
done