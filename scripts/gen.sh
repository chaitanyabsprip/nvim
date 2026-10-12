#!/bin/bash

depends tree || exit 1

main() {
	gen_manifest
	gentree >directory-structure.ls
}

gentree() {
	cd "$(dirname "$0")" || exit 1

	tree -I '.git' -P '*.lua' -P '*.vim' -P '*.scm' ..
}

gen_manifest() {
	{
		echo "["
		find .. -type d -name ".git" -prune -o -type f \( \
			-name "*.lua" -o -name "*.scm" -o -name "*.vim" \
			\) -print | sort | sed -e 's/.*/  "&",/' -e '$ s/,$//'
		echo "]"
	} >files.json
}

main "$@"
