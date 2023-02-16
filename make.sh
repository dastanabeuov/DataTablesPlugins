#!/bin/sh

DT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../.."
if [ "$1" = "debug" ]; then
	DEBUG="debug"
else
	OUT_DIR=$1
	DEBUG=$2
fi

# If not run from DataTables build script, redirect to there
if [ -z "$DT_BUILD" ]; then
	cd $DT_DIR/build
	./make.sh extension Plugins $DEBUG
	cd -
	exit
fi


function ts_plugin {
	local SRC_FILE=$1
	local REQUIRE=${2:-'datatables.net'}
	local DEST_DIR=$(dirname $(dirname $SRC_FILE))
	local FILE_NAME=$(basename $SRC_FILE)

	# Remove extension
	FILE_NAME="${FILE_NAME%.*}"

	./node_modules/.bin/tsc \
		--target esnext \
		--moduleResolution node \
		--outDir $DEST_DIR \
		--declaration \
		--allowSyntheticDefaultImports \
		$SRC_FILE

	# Remove import statements - the wrap will add them
	sed -i '/^import /d' $DEST_DIR/$FILE_NAME.js

	js_wrap $DEST_DIR/$FILE_NAME.js "$REQUIRE"
}

function js_plugin {
	local SRC_FILE=$1
	local REQUIRE=${2:-'datatables.net'}
	local DEST_DIR=$(dirname $(dirname $SRC_FILE))
	local FILE_NAME=$(basename $SRC_FILE)

	cp $SRC_FILE $DEST_DIR/$FILE_NAME
	js_wrap $DEST_DIR/$FILE_NAME "$REQUIRE"
}

# Change into script's own dir
cd $(dirname $0)

if [ ! -d node_modules ]; then
	npm install
fi

DT_SRC=$(dirname $(dirname $(pwd)))
DT_BUILT="${DT_SRC}/built/DataTables"
. $DT_SRC/build/include.sh

PLUGINS="${DT_SRC}/extensions/Plugins"

# for file in $PLUGINS/api/src/*.ts; do
# 	ts_plugin $file
# done

# for file in $PLUGINS/buttons/src/*.ts; do
# 	ts_plugin $file
# done

# for file in $PLUGINS/dataRender/src/*.ts; do
# 	ts_plugin $file
# done

# for file in $PLUGINS/features/*/src/*.ts; do
# 	ts_plugin $file "jquery datatables.net"
# done

# for file in $PLUGINS/sorting/src/*.ts; do
# 	ts_plugin $file
# done

# for file in $PLUGINS/type-detection/src/*.ts; do
# 	ts_plugin $file
# done

for file in $PLUGINS/filtering/type-based/src/*.ts; do
	ts_plugin $file
done


# # Only copying the integration files
# rsync -r integration     $OUT_DIR

