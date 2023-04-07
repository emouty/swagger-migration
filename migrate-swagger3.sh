#!/bin/bash

FILES_PATTERN=${1:-*.java}

FILES=$(find . -name "$FILES_PATTERN")

echo ''
echo "Migrating Swagger v2 to Swagger v3 OpenAPI annotations"
echo ''

EXPRESSION="s/import io\.swagger\.annotations\.Api;/import io\.swagger\.v3\.oas\.annotations\.OpenAPIDefinition;\nimport io\.swagger\.v3\.oas\.annotations\.tags.Tag;/g;\
s/io\.swagger\.annotations\.ApiOperation;/io\.swagger\.v3\.oas\.annotations\.Operation;/g;\
s/import io\.swagger\.annotations\.ApiParam;/import io\.swagger\.v3\.oas\.annotations\.Parameter;\nimport io\.swagger\.v3\.oas\.annotations\.media\.Schema;/g;\
s/import io\.swagger\.annotations\.ApiResponse;/import io\.swagger\.v3\.oas\.annotations\.media\.Content;\nimport io\.swagger\.v3\.oas\.annotations\.media\.Schema;\nimport io\.swagger\.v3\.oas\.annotations\.responses\.ApiResponse;/g;\
s/io\.swagger\.annotations\.ApiResponses;/io\.swagger\.v3\.oas\.annotations\.responses\.ApiResponses;/g;\
s/io\.swagger\.annotations\.ApiModelProperty;/io\.swagger\.v3\.oas\.annotations\.media.Schema;/g;\
s/io\.swagger\.annotations\.ApiModelProperty;/io\.swagger\.v3\.oas\.annotations\.media\.Schema;/g;\
s/io.swagger.annotations.ApiModel;/io\.swagger\.v3\.oas\.annotations\.media\.Schema;/g;\
s/@Api$/@OpenAPIDefinition/g;\
s/@Api(\s*value = \"\([^)]*\)\"/@Tag(name = \"\1\"/g;\
s/@Api(\s*tags = \"\([^)]*\)\"/@Tag(name = \"\1\"/g;\
s/@Api(\"\([^)]*\)\"/@Tag(name = \"\1\"/g;\
s/@ApiOperation(\s*value = \"\([^\"]*\)\",\n*\s*notes = \"\([^)]*\))/@Operation(summary = \"\1\", description = \"\2)/g;\
s/@ApiOperation(\s*value = \"\([^,]*\)\",/@Operation(summary = \"\1\",/g;\
s/@ApiOperation(\s*value = /@Operation(summary = /g;\
s/@ApiOperation(\s*/@Operation(summary = /g;\
s/\(\n\{1\}\s*\)@ApiResponse(code = \([0-9]\{3\}\),\n*\s*message = \"\([^\"]*\)\",\n*\s*response = \([a-Z]*\.class)\)/\1@ApiResponse(responseCode = \"\2\", description = \"\3\", content = @Content(schema = @Schema(implementation = \4))/g;\
s/@ApiResponse(code = \([0-9]\{3\}\),\r*\n*\s*message = \"\([^)]*\)\")/@ApiResponse(responseCode = \"\1\", description = \"\2\")/g;\
s/@ApiParam(\n*\s*required = \([^,]\), value = \"\([^)]*\)\")/@Parameter(required = \1, description = \"\2\")/g;\
s/@ApiParam(\n*\s*value = \"\([^\"]*\)\", allowableValues = \"\([^\"]*\)\", required = \([^)]*\))/@Parameter(required = \3,  schema = @Schema(allowableValues = \"\2\"), description = \"\1\")/g;\
s/@ApiParam(\n*\s*value = \"\([^\"]*\)\", required = \([^)]*\))/@Parameter(required = \2, description = \"\1\")/g;\
s/@ApiParam(\n*\s*\"\([^)]*\)\")/@Parameter(description = \"\1\")/g;\
s/@ApiParam(\n*\s*value = \"\([^)]*\)\")/@Parameter(description = \"\1\")/g;\
s/@ApiModelProperty(\n*\s*\"/@Schema(description = \"/g;\
s/@ApiModelProperty(\n*\s*notes/@Schema(description/g;\
s/@ApiModelProperty(\n*\s*value/@Schema(description/g;\
s/@ApiModelProperty(\n*\s*name = \"\([^\"]*\)\",\n*\s*value = \"\([^\"]*\)\",\n*\s*required = \([^)]*\))/@Schema( name = \"\1\", description = \"\2\", required = \3)/g;\
s/@ApiModelProperty(\n*\s*name = \"\([^\"]*\)\",\n*\s*value = \"\([^\"]*\)\",\n*\s*notes = \([^)]*\))/@Schema( name = \"\1\", description = \"\"\"\n\2\n\3\n\"\"\")/g;\
s/@ApiModelProperty(\n*\s*name = \"\([^\"]*\)\",\n*\s*value = \"\([^)]*\))/@Schema( name = \"\1\", description = \"\2)/g;\
s/@ApiModel(\n*\s*value = \"\([^\"]*\)\",\n*\s*description = \"\([^)]*\))/@Schema( name = \"\1\", description = \"\2)/g;\
s/@ApiResponses({\([^}]*\)})/\1/g;\
s/@ApiResponse(\([^)]*\)\([^\"])*\),\n/@ApiResponse(\1\2\n/g;\
"

for FILE in $FILES; do
    CMD="sed -z -i -e '${EXPRESSION}' '${FILE}'"

    echo ''
    echo "Migrating ${FILE} ..."
    eval ${CMD}
done

echo ''
echo 'Done!'
echo ''
echo 'Note that if you are using reponse parameter in the @ApiResponse annotation then your'
echo 'codebase, you will need to enable [Add unambiguous imports on the fly] option in your IDE.'
echo 'This is because @Content and @Schema are annotations that are being added for the first time.'
echo ''
echo 'This script is not a complete solution, it does not cover cases where the string is concatenated'
echo 'by a plus sign.'
echo ''
echo 'If your project has annotations not in the script, please slack me to update the script. :)'
