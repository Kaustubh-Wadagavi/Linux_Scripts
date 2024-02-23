#!/bin/bash

# Define input and output file paths
input_file="input.csv"
output_file="output.csv"

# Function to extract data for a specific patient
extract_patient_data() {
    local patient_id="$1"
    local fields=()
    local data=()
    local header=""
    
    # Read data line by line
    while IFS=, read -r pid field value; do
        if [[ "$pid" == "$patient_id" ]]; then
            if [[ ! "${fields[@]}" ]]; then
                header="$value"
            fi
            fields+=("$field")
            data+=("$value")
        fi
    done < "$input_file"
    
    # Generate the output line
    local output_line="$patient_id"
    for ((i=0; i<${#fields[@]}; i++)); do
        output_line="$output_line,${data[i]}"
    done
    
    echo "$output_line"
}

# Extract unique patients from input file
unique_patients=$(cut -d ',' -f1 "$input_file" | grep -v "Patient" | sort | uniq)

# Create header line for output file
header=$(cut -d ',' -f2 "$input_file" | grep -v "Fields" | sort | uniq | tr '\n' ',' | sed 's/,$//')
echo "Patient,$header" > "$output_file"

# Process each unique patient
while IFS= read -r patient; do
    extract_patient_data "$patient" >> "$output_file"
done <<< "$unique_patients"

echo "Output written to $output_file"
