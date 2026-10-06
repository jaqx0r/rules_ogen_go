#!/usr/bin/env sh
#
set -eu

export PATH="$(readlink -f "{{goroot}}")/bin:$PATH"
mkdir -p "{{target}}"
{{ogen}} --target "{{target}}" --package "{{package}}" {{config_flags}} "{{spec}}"

# ogen omits certain files when the spec does not require them, but to keep the output list stable make sure they all exist.
for file in {{expected_outputs}}; do
    path="{{target}}/{{file}}"
    if [ ! -f "${path}" ]; then
        {
            printf '%s\n' '// Code generates by ogen_wrapper_template.sh. DO NOT EDIT.'
            printf '\npackage %s\n' '{{package}}'
        } >"${path}"
    fi
done

