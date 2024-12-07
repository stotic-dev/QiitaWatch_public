# Paths
PROJECT_PATH=./QiitaWatch/

# File extensions
PROJECT_EXTENSION=.xcodeproj

# Definition
PROJECT_NAME=`find $(PROJECT_PATH) -maxdepth 1 -mindepth 1 -iname "*$(PROJECT_EXTENSION)" | xargs -L 1 -I {} basename "{}" $(PROJECT_EXTENSION)`
PROJECT=$(PROJECT_PATH)$(PROJECT_NAME)$(PROJECT_EXTENSION)
XCODE_VERSION=`cat $(PROJECT_PATH).xcode-version`

# 一括で環境構築を行う
setup:
	make resolve-dependency
	open $(PROJECT)

# Xcode を開く
open:
	open $(PROJECT)

# SPMの依存関係を解決する
resolve-dependency:
	xcodebuild -resolvePackageDependencies -project ${PROJECT}