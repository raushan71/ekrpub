builds:
	dart run build_runner build --delete-conflicting-outputs

languages:
	flutter pub run intl_utils:generate

clean:
	flutter clean && flutter pub get 

apk_build:
	flutter build apk

split_apk_build:
	flutter build apk --split-per-abi