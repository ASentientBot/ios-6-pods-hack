set -e
PATH+=:/usr/libexec
cd "$(dirname "$0")"

name=ios-6-pods-hack
target=SpringBoard
version=1

rm -rf package
mkdir -p package/Library/MobileSubstrate/DynamicLibraries package/DEBIAN
dylib="package/Library/MobileSubstrate/DynamicLibraries/$name.dylib"
plist="package/Library/MobileSubstrate/DynamicLibraries/$name.plist"
control=package/DEBIAN/control
deb="$name.deb"

# https://github.com/anars/blank-audio/raw/master/1-minute-of-silence.mp3
xxd -i silence.mp3 > silence.h

xcrun -sdk iphoneos clang -dynamiclib -fmodules -Wno-unused-getter-return-value -arch armv7 -miphoneos-version-min=6 -F . -framework CydiaSubstrate main.m -o "$dylib"

PlistBuddy -c 'add Filter:Executables array' "$plist"
PlistBuddy -c "add Filter:Executables:0 string $target" "$plist"

echo "Package:$name" > "$control"
echo "Version:$version" >> "$control"
echo Architecture:iphoneos-arm >> "$control"
echo Depends:mobilesubstrate >> "$control"

dpkg-deb -Z none -b package "$deb"