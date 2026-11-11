#!/usr/bin/env bash
#
# inspect-ios-build.sh - read-only inspection of a built iOS app (.ipa, .xcarchive or .app)
# for App Store submission problems that only show up in the binary, e.g.:
#   ITMS-91053  required-reason API used but not declared in a privacy manifest
#   ITMS-91061  SDK from Apple's "commonly used third-party SDKs" list shipped without a privacy manifest
#   ITMS-90683  API linked in the binary but its NS*UsageDescription purpose string is missing
#   ATS exceptions, debug entitlements (get-task-allow), background modes, SDK version, ...
#
# Output: plain text, stable "=== SECTION ===" headings. Line prefixes:
#   POSSIBLE ITMS-xxxxx:  likely App Store Connect rejection/warning (heuristic - verify)
#   WARN:                 something a reviewer or the upload validator may object to
#   INFO:                 context only
#   SKIPPED:              an optional tool was missing, so a check did not run
# All findings are repeated in the final "=== SUMMARY ===" section.
#
# Everything symbol-based is a HEURISTIC: a symbol being present does not prove the code path
# runs, and its absence does not prove compliance (stripped/obfuscated binaries, dynamic lookups).
#
# No network access, nothing is installed, the input is never modified (an .ipa is unzipped
# into a temp dir that is removed on exit).
#
# Optional tools (each check degrades gracefully when missing):
#   plutil or python3   read binary/XML plists            jq        structured plist queries
#   codesign            entitlements of the signed app    security  decode embedded.mobileprovision
#   nm                  undefined-symbol listing          strings   string extraction (tr fallback)
#   otool               linked library list               lipo      architectures
# Required only for .ipa input: unzip
#
# Exit codes: 0 = inspection ran (findings are not errors); 2 = bad usage or input;
#             3 = a tool required for this input type is missing.

set -euo pipefail
# Byte-oriented text tools: faster on binaries and no "illegal byte sequence" errors.
export LC_ALL=C

PROG="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $PROG <path-to .ipa | .xcarchive | .app>

Read-only inspection of a built iOS app for App Store submission problems
(privacy manifests / ITMS-91053 / ITMS-91061, purpose strings, entitlements,
ATS, background modes, embedded SDKs, hardcoded hosts).

Options:
  -h, --help    Show this help and exit.

Exit codes: 0 inspection ran (findings are not errors), 2 bad input, 3 missing required tool.
EOF
}

die() { printf '%s: error: %s\n' "$PROG" "$1" >&2; exit "${2:-2}"; }

# ---------------------------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------------------------
if [ "$#" -ne 1 ]; then
  usage >&2
  exit 2
fi
case "$1" in
  -h|--help) usage; exit 0 ;;
  -*) usage >&2; exit 2 ;;
esac

INPUT="${1%/}"
[ -e "$INPUT" ] || die "no such file or directory: $INPUT"

# ---------------------------------------------------------------------------------------------
# Tool detection
# ---------------------------------------------------------------------------------------------
OS="$(uname -s)"
# On macOS, /usr/bin/{nm,strings,otool,lipo,python3,...} are stubs that pop up an
# "install Command Line Tools" dialog when the CLT/Xcode are missing. Never trigger that.
CLT_OK=1
if [ "$OS" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then CLT_OK=0; fi

have() {
  local p
  p="$(command -v "$1" 2>/dev/null)" || return 1
  if [ "$OS" = "Darwin" ] && [ "$CLT_OK" = 0 ]; then
    case "$p" in
      /usr/bin/nm|/usr/bin/strings|/usr/bin/otool|/usr/bin/lipo|/usr/bin/python3|/usr/bin/xcrun|/usr/bin/objdump) return 1 ;;
    esac
  fi
  return 0
}

b() { if have "$1"; then echo 1; else echo 0; fi; }
HAVE_PLUTIL="$(b plutil)"
HAVE_JQ="$(b jq)"
HAVE_CODESIGN="$(b codesign)"
HAVE_SECURITY="$(b security)"
HAVE_OPENSSL="$(b openssl)"
HAVE_NM="$(b nm)"
HAVE_STRINGS="$(b strings)"
HAVE_OTOOL="$(b otool)"
HAVE_LIPO="$(b lipo)"
HAVE_FILE="$(b file)"
HAVE_UNZIP="$(b unzip)"
HAVE_PYTHON=0
if have python3 && python3 -I -c 'import plistlib, json' >/dev/null 2>&1; then HAVE_PYTHON=1; fi

# Structured plist parsing needs a converter (plutil or python3) plus jq for queries.
STRUCT=0
if [ "$HAVE_JQ" = 1 ] && { [ "$HAVE_PLUTIL" = 1 ] || [ "$HAVE_PYTHON" = 1 ]; }; then STRUCT=1; fi

# ---------------------------------------------------------------------------------------------
# Temp dir + output helpers
# ---------------------------------------------------------------------------------------------
TMP="$(mktemp -d "${TMPDIR:-/tmp}/inspect-ios.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
trap 'exit 130' INT TERM

FLAGS="$TMP/flags.txt"; : > "$FLAGS"
SKIPS="$TMP/skips.txt"; : > "$SKIPS"

section() { printf '\n=== %s ===\n' "$1"; }
info()    { printf '%s\n' "$*"; }
flag()    { printf '%s\n' "$*"; printf '%s\n' "$*" >> "$FLAGS"; }
skip()    { printf 'SKIPPED: %s\n' "$*"; printf 'SKIPPED: %s\n' "$*" >> "$SKIPS"; }

# plist_to_json <plist> <out.json> : binary or XML plist -> JSON. Returns 1 if impossible.
plist_to_json() {
  if [ "$HAVE_PLUTIL" = 1 ] && plutil -convert json -o "$2" "$1" >/dev/null 2>&1; then
    return 0
  fi
  # plutil refuses <date>/<data> values in JSON; python3 can stringify them.
  if [ "$HAVE_PYTHON" = 1 ]; then
    python3 -I -c '
import sys, json, plistlib, datetime
with open(sys.argv[1], "rb") as f:
    d = plistlib.load(f)
def conv(o):
    if isinstance(o, (bytes, bytearray)):
        return "<data %d bytes>" % len(o)
    if isinstance(o, datetime.datetime):
        return o.isoformat()
    return str(o)
with open(sys.argv[2], "w") as f:
    json.dump(d, f, default=conv)
' "$1" "$2" >/dev/null 2>&1 && return 0
  fi
  return 1
}

# plist_raw <plist> : best-effort human-readable dump when structured parsing is unavailable.
plist_raw() {
  if [ "$HAVE_PLUTIL" = 1 ] && plutil -p "$1" 2>/dev/null; then return 0; fi
  if head -c 6 "$1" 2>/dev/null | grep -q 'bplist'; then
    # Key names are stored as plain ASCII in binary plists; values cannot be associated.
    info "(binary plist - values unreadable without plutil or python3; key names found:)"
    LC_ALL=C tr -c '[:alnum:]_~-' '\n' < "$1" | grep -oE '^_?(NS|UI|CF|LS|NFC|IT|DT|BG)[A-Za-z0-9_~-]{3,}$' | sed 's/^_//; s/_$//' | sort -u | sed 's/^/  /' || true
  else
    sed -n '1,300p' "$1"
  fi
}

# xml_norm <file> : put every XML tag on its own line (codesign --xml output is one long line).
xml_norm() { awk '{ gsub(/></, ">\n<"); print }' "$1"; }

# xml_key_value <xml-plist> <key> : value element following <key>key</key> (top-level or not),
# with simple tags stripped: "true", "false", "development", "2026-01-01T00:00:00Z", "<array>"...
xml_key_value() {
  xml_norm "$1" | awk -v k="<key>$2</key>" '
    found { sub(/^[ \t]+/, ""); print; exit }
    { line = $0; sub(/^[ \t]+/, "", line); if (line == k) found = 1 }' |
    sed -E 's#</?(string|date|integer|real)>##g; s#<(true|false)/>#\1#'
}

# extract_strings <binary> : printable strings (strings(1) when available, tr fallback).
extract_strings() {
  if [ "$HAVE_STRINGS" = 1 ]; then
    strings -a "$1" 2>/dev/null || true
  else
    LC_ALL=C tr -c '[:print:]' '\n' < "$1" | grep -E '.{4,}' || true
  fi
}

# make_symfile <binary> <out> : undefined symbols (nm -u) + all strings, one per line.
# Imported symbol names live in the string table, so even without nm the strings output
# contains lines like "_stat" or "_OBJC_CLASS_$_NSUserDefaults".
# Side files: <out>.nm (undefined symbols only) and <out>.str (strings only).
make_symfile() {
  : > "$2"; : > "$2.nm"; : > "$2.str"
  [ -f "$1" ] || return 0
  if [ "$HAVE_NM" = 1 ]; then
    nm -u "$1" 2>/dev/null | sed -E 's/^[[:space:]]*(U[[:space:]]+)?//' > "$2.nm" || true
  fi
  extract_strings "$1" > "$2.str"
  cat "$2.nm" "$2.str" > "$2"
}

rel() { case "$1" in "$APP"/*) printf '%s' "${1#"$APP"/}" ;; *) printf '%s' "$1" ;; esac; }
lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# ---------------------------------------------------------------------------------------------
# Resolve the .app bundle
# ---------------------------------------------------------------------------------------------
INPUT_KIND=""
case "$(lower "$INPUT")" in
  *.ipa)
    INPUT_KIND="ipa"
    [ -f "$INPUT" ] || die "not a file: $INPUT"
    [ "$HAVE_UNZIP" = 1 ] || die "unzip is required to inspect an .ipa (or pass the .app / .xcarchive instead)" 3
    mkdir -p "$TMP/ipa"
    unzip -qq -o "$INPUT" -d "$TMP/ipa" >/dev/null 2>&1 || die "could not unzip (not a valid .ipa?): $INPUT"
    APP="$(find "$TMP/ipa/Payload" -maxdepth 1 -type d -name '*.app' 2>/dev/null | head -n 1 || true)"
    [ -n "$APP" ] || die "no Payload/*.app inside the .ipa"
    ;;
  *.xcarchive)
    INPUT_KIND="xcarchive"
    APP="$(find "$INPUT/Products/Applications" -maxdepth 1 -type d -name '*.app' 2>/dev/null | head -n 1 || true)"
    [ -n "$APP" ] || die "no Products/Applications/*.app inside the .xcarchive"
    ;;
  *.app)
    INPUT_KIND="app"
    APP="$INPUT"
    ;;
  *) die "unsupported input (expected .ipa, .xcarchive or .app): $INPUT" ;;
esac
[ -d "$APP" ] || die "not a bundle directory: $APP"
if [ ! -f "$APP/Info.plist" ]; then
  if [ -f "$APP/Contents/Info.plist" ]; then die "this looks like a macOS app bundle; this script inspects iOS builds"; fi
  die "no Info.plist in $APP"
fi

# ---------------------------------------------------------------------------------------------
# Static tables
# ---------------------------------------------------------------------------------------------

# Apple's list of "commonly used third-party SDKs" that must ship a privacy manifest (and a
# signature when distributed as a binary). Source: Apple developer docs "Upcoming third-party
# SDK requirements" (2023-12; enforced since 2025-02-12). CHECK AGAINST APPLE'S CURRENT PAGE -
# the list can change. Matching below is case-insensitive on framework/bundle names.
APPLE_SDK_LIST=(
  Abseil AFNetworking Alamofire AppAuth BoringSSL openssl_grpc Capacitor Charts
  connectivity_plus Cordova device_info_plus DKImagePickerController DKPhotoGallery
  FBAEMKit FBLPromises FBSDKCoreKit FBSDKCoreKit_Basics FBSDKLoginKit FBSDKShareKit
  file_picker FirebaseABTesting FirebaseAuth FirebaseCore FirebaseCoreDiagnostics
  FirebaseCoreExtension FirebaseCoreInternal FirebaseCrashlytics FirebaseDynamicLinks
  FirebaseFirestore FirebaseInstallations FirebaseMessaging FirebaseRemoteConfig Flutter
  flutter_inappwebview flutter_local_notifications fluttertoast FMDB geolocator_apple
  GoogleDataTransport GoogleSignIn GoogleToolboxForMac GoogleUtilities grpcpp GTMAppAuth
  GTMSessionFetcher hermes image_picker_ios IQKeyboardManager IQKeyboardManagerSwift
  Kingfisher leveldb Lottie MBProgressHUD nanopb OneSignal OneSignalCore OneSignalExtension
  OneSignalOutcomes OpenSSL OrderedSet package_info package_info_plus path_provider
  path_provider_ios Promises Protobuf Reachability RealmSwift RxCocoa RxRelay RxSwift
  SDWebImage share_plus shared_preferences_ios SnapKit sqflite Starscream SVProgressHUD
  SwiftyGif SwiftyJSON Toast UnityFramework url_launcher url_launcher_ios
  video_player_avfoundation wakelock webview_flutter_wkwebview
)
# Built-product names that differ from the names on Apple's list ("built-name:ListName").
SDK_ALIASES=(
  "absl:Abseil" "DGCharts:Charts" "Toast_Swift:Toast" "FirebaseFirestoreInternal:FirebaseFirestore"
  "grpc:grpcpp" "lottie_ios:Lottie" "Protobuf_Privacy:Protobuf" "AppAuthCore:AppAuth"
  "ReachabilitySwift:Reachability" "OneSignalFramework:OneSignal" "GTMSessionFetcherCore:GTMSessionFetcher"
)

# Lookup table "lowercase-name<TAB>ListName" (aliases first), built once.
SDK_TABLE="$TMP/sdk-table.tsv"
{
  for a in "${SDK_ALIASES[@]}"; do printf '%s\t%s\n' "${a%%:*}" "${a#*:}"; done
  for s in "${APPLE_SDK_LIST[@]}"; do printf '%s\t%s\n' "$s" "$s"; done
} | awk -F'\t' '{ print tolower($1) "\t" $2 }' > "$SDK_TABLE"

# sdk_canonical <name> : prints the Apple-list name if <name> is on the list, else returns 1.
sdk_canonical() {
  [ -n "$1" ] || return 1
  awk -F'\t' -v n="$1" 'BEGIN { n = tolower(n) } $1 == n { print $2; f = 1; exit } END { exit !f }' "$SDK_TABLE"
}

# Markers for SDKs that are statically linked into the main binary (no .framework to look at).
# "token<TAB>SDK" - token is a fixed substring searched in the binary's strings: ObjC class
# prefixes, or Swift mangled module names (<length><Module>). Lower confidence than frameworks.
STATIC_MARKERS="$TMP/static-markers.tsv"
cat > "$STATIC_MARKERS" <<'EOF'
AFHTTPSessionManager	AFNetworking
9Alamofire	Alamofire
OIDAuthorizationService	AppAuth
CAPBridgeViewController	Capacitor
CDVViewController	Cordova
8DGCharts	Charts
23DKImagePickerController	DKImagePickerController
FBSDKApplicationDelegate	FBSDKCoreKit
FBSDKLoginManager	FBSDKLoginKit
FBSDKShareDialog	FBSDKShareKit
FBLPromise	FBLPromises
FIRApp	FirebaseCore
20FirebaseCoreInternal	FirebaseCoreInternal
FIRCrashlytics	FirebaseCrashlytics
FIRMessaging	FirebaseMessaging
FIRInstallations	FirebaseInstallations
FIRRemoteConfig	FirebaseRemoteConfig
FIRAuthDataResult	FirebaseAuth
FIRFirestore	FirebaseFirestore
FIRExperimentController	FirebaseABTesting
FIRDynamicLinks	FirebaseDynamicLinks
FMDatabase	FMDB
GDTCORTransport	GoogleDataTransport
GULAppEnvironmentUtil	GoogleUtilities
GIDSignIn	GoogleSignIn
GTMSessionFetcher	GTMSessionFetcher
GTMAppAuthFetcherAuthorization	GTMAppAuth
GTMLogger	GoogleToolboxForMac
IQKeyboardManager	IQKeyboardManager
10Kingfisher	Kingfisher
6Lottie	Lottie
MBProgressHUD	MBProgressHUD
SVProgressHUD	SVProgressHUD
OneSignal	OneSignal
8Promises	Promises
12Reachability	Reachability
10RealmSwift	RealmSwift
7RxSwift	RxSwift
7RxCocoa	RxCocoa
7RxRelay	RxRelay
SDWebImageManager	SDWebImage
7SnapKit	SnapKit
10Starscream	Starscream
10SwiftyJSON	SwiftyJSON
9SwiftyGif	SwiftyGif
CSToastManager	Toast
11Toast_Swift	Toast
EOF

# Required-reason API categories and the binary signals we look for.
# Sources: Apple "Describing use of required reason API". Signals are matched line-by-line
# against nm -u + strings output: C functions as imported symbols (leading "_"), Foundation
# constants (NSURL*Key / NSFile*), ObjC selectors as exact lines, Swift Foundation mangled names
# as substrings. Expect some false positives (e.g. PHAsset.creationDate also matches).
CATEGORIES="FileTimestamp SystemBootTime DiskSpace ActiveKeyboards UserDefaults"
cat_pattern() {
  case "$1" in
    FileTimestamp)
      printf '%s' '^(_(stat|stat64|lstat|lstat64|fstat|fstat64|fstatat|getattrlist|getattrlistbulk|fgetattrlist|getattrlistat)(\$INODE64)?|_?NSFileCreationDate|_?NSFileModificationDate|_?NSURLCreationDateKey|_?NSURLContentModificationDateKey|_?NSURLContentAccessDateKey|creationDate|contentModificationDate|modificationDate|fileModificationDate|fileCreationDate)$|URLResourceValuesV[0-9]+(creationDate|contentModificationDate|contentAccessDate)' ;;
    SystemBootTime)
      printf '%s' '^(_mach_absolute_time|systemUptime|kern\.boottime)$' ;;
    DiskSpace)
      printf '%s' '^(_(statfs|statfs64|fstatfs|fstatfs64|statvfs|fstatvfs)(\$INODE64)?|_?NSURLVolumeAvailableCapacityKey|_?NSURLVolumeAvailableCapacityForImportantUsageKey|_?NSURLVolumeAvailableCapacityForOpportunisticUsageKey|_?NSURLVolumeTotalCapacityKey|_?NSFileSystemFreeSize|_?NSFileSystemSize)$|URLResourceValuesV[0-9]+volume(Available|Total)Capacity' ;;
    ActiveKeyboards)
      printf '%s' '^(activeInputModes)$' ;;
    UserDefaults)
      printf '%s' 'NSUserDefaults|^standardUserDefaults$' ;;
  esac
}
# Approved reason codes per category (used to validate manifests).
cat_reasons() {
  case "$1" in
    FileTimestamp)   echo "DDA9.1 C617.1 3B52.1 0A2A.1" ;;
    SystemBootTime)  echo "35F9.1 8FFB.1 3D61.1" ;;
    DiskSpace)       echo "85F4.1 E174.1 7D9E.1 B728.1" ;;
    ActiveKeyboards) echo "3EC4.1 54BD.1" ;;
    UserDefaults)    echo "CA92.1 1C8F.1 C56D.1 AC6B.1" ;;
  esac
}

# API markers -> purpose-string key (ITMS-90683 is raised for APIs linked in ANY binary,
# including third-party SDK code the app never calls). "symbol<TAB>key1|key2" - any key satisfies.
USAGE_MARKERS="$TMP/usage-markers.tsv"
cat > "$USAGE_MARKERS" <<'EOF'
_OBJC_CLASS_$_AVCaptureDevice	NSCameraUsageDescription
_OBJC_CLASS_$_AVAudioRecorder	NSMicrophoneUsageDescription
requestRecordPermission:	NSMicrophoneUsageDescription
requestRecordPermissionWithCompletionHandler:	NSMicrophoneUsageDescription
_OBJC_CLASS_$_PHPhotoLibrary	NSPhotoLibraryUsageDescription|NSPhotoLibraryAddUsageDescription
_UIImageWriteToSavedPhotosAlbum	NSPhotoLibraryAddUsageDescription|NSPhotoLibraryUsageDescription
_OBJC_CLASS_$_CLLocationManager	NSLocationWhenInUseUsageDescription|NSLocationAlwaysAndWhenInUseUsageDescription
requestAlwaysAuthorization	NSLocationAlwaysAndWhenInUseUsageDescription
_OBJC_CLASS_$_CNContactStore	NSContactsUsageDescription
_OBJC_CLASS_$_EKEventStore	NSCalendarsFullAccessUsageDescription|NSCalendarsWriteOnlyAccessUsageDescription|NSCalendarsUsageDescription|NSRemindersFullAccessUsageDescription|NSRemindersUsageDescription
_OBJC_CLASS_$_CBCentralManager	NSBluetoothAlwaysUsageDescription
_OBJC_CLASS_$_CBPeripheralManager	NSBluetoothAlwaysUsageDescription
_OBJC_CLASS_$_CMMotionActivityManager	NSMotionUsageDescription
_OBJC_CLASS_$_CMPedometer	NSMotionUsageDescription
_OBJC_CLASS_$_HKHealthStore	NSHealthShareUsageDescription|NSHealthUpdateUsageDescription
_OBJC_CLASS_$_SFSpeechRecognizer	NSSpeechRecognitionUsageDescription
_OBJC_CLASS_$_MPMediaLibrary	NSAppleMusicUsageDescription
_OBJC_CLASS_$_MPMediaQuery	NSAppleMusicUsageDescription
_OBJC_CLASS_$_LAContext	NSFaceIDUsageDescription
_OBJC_CLASS_$_ATTrackingManager	NSUserTrackingUsageDescription
_OBJC_CLASS_$_NFCNDEFReaderSession	NFCReaderUsageDescription
_OBJC_CLASS_$_NFCTagReaderSession	NFCReaderUsageDescription
_OBJC_CLASS_$_HMHomeManager	NSHomeKitUsageDescription
_OBJC_CLASS_$_INPreferences	NSSiriUsageDescription
_OBJC_CLASS_$_NISession	NSNearbyInteractionUsageDescription
EOF

# Apple's minimum SDK for uploads. Since 2026-04-28 App Store Connect requires the iOS 26 SDK
# (Xcode 26). Update this constant when Apple raises the requirement.
REQUIRED_MIN_SDK_MAJOR=26

# ---------------------------------------------------------------------------------------------
# Header + tools
# ---------------------------------------------------------------------------------------------
printf 'inspect-ios-build report\n'
printf 'input_type: %s\n' "$INPUT_KIND"
printf 'app_bundle: %s\n' "$(basename "$APP")"
printf 'generated: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
info "NOTE: symbol/string checks are heuristics; verify each finding before acting on it."

section "TOOLS"
for t in plutil python3 jq codesign security openssl nm strings otool lipo file unzip; do
  case "$t" in
    python3) v="$HAVE_PYTHON" ;;
    *) v="$(b "$t")" ;;
  esac
  if [ "$v" = 1 ]; then printf '%-9s available\n' "$t"; else printf '%-9s missing\n' "$t"; fi
done
if [ "$OS" = "Darwin" ] && [ "$CLT_OK" = 0 ]; then
  info "INFO: Xcode Command Line Tools not installed; nm/strings/otool/lipo/python3 treated as missing."
fi
[ "$STRUCT" = 1 ] || skip "structured plist parsing (needs jq + plutil or python3): plist sections fall back to raw dumps and grep"
[ "$HAVE_NM" = 1 ] || skip "nm: undefined-symbol listing; symbol checks use string extraction only"
[ "$HAVE_STRINGS" = 1 ] || info "INFO: strings(1) missing; using tr-based string extraction"

# ---------------------------------------------------------------------------------------------
# Info.plist
# ---------------------------------------------------------------------------------------------
INFO_JSON="$TMP/info.json"
INFO_OK=0
if [ "$STRUCT" = 1 ] && plist_to_json "$APP/Info.plist" "$INFO_JSON"; then INFO_OK=1; fi
ij() { jq -r "$1" "$INFO_JSON" 2>/dev/null || true; }
ihas() { [ "$INFO_OK" = 1 ] && [ "$(jq -r --arg k "$1" 'has($k)' "$INFO_JSON" 2>/dev/null)" = "true" ]; }

section "APP INFO.PLIST"
EXEC_NAME=""
SDK_NAME=""
PLATFORM=""
if [ "$INFO_OK" = 1 ]; then
  EXEC_NAME="$(ij '.CFBundleExecutable // empty')"
  SDK_NAME="$(ij '.DTSDKName // empty')"
  PLATFORM="$(ij '.DTPlatformName // empty')"
  info "bundle_id: $(ij '.CFBundleIdentifier // "-"')"
  info "version: $(ij '.CFBundleShortVersionString // "-"')"
  info "build: $(ij '.CFBundleVersion // "-"')"
  info "executable: ${EXEC_NAME:--}"
  info "minimum_os: $(ij '.MinimumOSVersion // "-"')"
  info "device_family: $(ij '[.UIDeviceFamily[]? | tostring | if .=="1" then "1(iPhone)" elif .=="2" then "2(iPad)" elif .=="3" then "3(tvOS)" elif .=="4" then "4(watchOS)" elif .=="6" then "6(Mac)" elif .=="7" then "7(visionOS)" else . end] | join(", ")')"
  info "platform: ${PLATFORM:--}"
  info "sdk: ${SDK_NAME:--}"
  info "xcode: $(ij '.DTXcode // "-"')  xcode_build: $(ij '.DTXcodeBuild // "-"')"
  info "encryption_exempt_key (ITSAppUsesNonExemptEncryption): $(ij 'if has("ITSAppUsesNonExemptEncryption") then (.ITSAppUsesNonExemptEncryption|tostring) else "not set" end')"

  if [ "$PLATFORM" = "iphonesimulator" ]; then
    flag "WARN: built for the iOS Simulator (DTPlatformName=iphonesimulator) - not an uploadable build; results for signing/entitlements are not representative"
  fi
  sdk_major="$(printf '%s' "$SDK_NAME" | sed -nE 's/^[a-z]+([0-9]+).*/\1/p')"
  if [ -n "$sdk_major" ] && [ "$sdk_major" -lt "$REQUIRED_MIN_SDK_MAJOR" ]; then
    flag "POSSIBLE ITMS-90725: built with $SDK_NAME; uploads currently require the iOS $REQUIRED_MIN_SDK_MAJOR SDK or later (verify Apple's current requirement)"
  fi
  if ! ihas UILaunchStoryboardName && ! ihas UILaunchScreen; then
    flag "WARN: no UILaunchStoryboardName or UILaunchScreen - App Store requires a launch storyboard/launch screen"
  fi

  info ""
  info "-- usage descriptions (purpose strings) --"
  ud="$(ij 'to_entries[] | select(.key|test("UsageDescription$")) | "\(.key) = \(.value|tostring)"')"
  if [ -n "$ud" ]; then
    printf '%s\n' "$ud"
    # Very short / placeholder purpose strings are a common 5.1.1 rejection.
    short="$(ij 'to_entries[] | select(.key|test("UsageDescription$")) | select((.value|tostring|length) < 12 or (.value|tostring|test("^(TODO|test|usage|description|\\$\\(.*\\))$";"i"))) | .key')"
    if [ -n "$short" ]; then
      while IFS= read -r k; do flag "WARN: purpose string $k is empty/placeholder-like (Guideline 5.1.1(ii) needs a clear, specific explanation)"; done <<< "$short"
    fi
    # Generic "Allow X to access your Y" strings (the React Native/Expo plugin defaults) do not
    # say WHY access is needed and are a frequent 5.1.1(ii) rejection.
    generic="$(ij 'to_entries[] | select(.key|test("UsageDescription$")) | select(.value|tostring|test("^Allow .+ to (access|use) (your|the) [A-Za-z ]+\\.?$")) | .key')"
    if [ -n "$generic" ]; then
      while IFS= read -r k; do flag "WARN: purpose string $k looks generic (\"Allow ... to access your ...\") - say why the app needs it (Guideline 5.1.1(ii))"; done <<< "$generic"
    fi
  else
    info "(none)"
  fi
  lproj="$(find "$APP" -maxdepth 2 -name InfoPlist.strings 2>/dev/null | sed -E 's#.*/([^/]+)\.lproj/InfoPlist\.strings#\1#' | sort | tr '\n' ' ' || true)"
  [ -z "$lproj" ] || info "INFO: localized InfoPlist.strings (may override purpose strings): $lproj"

  info ""
  info "-- NSAppTransportSecurity --"
  ats="$(ij '.NSAppTransportSecurity // empty | tojson')"
  info "${ats:-(not set - ATS fully enforced)}"
  if [ "$(ij '.NSAppTransportSecurity.NSAllowsArbitraryLoads // false')" = "true" ]; then
    flag "WARN: NSAllowsArbitraryLoads=true - ATS disabled globally; App Review may ask for justification (Guideline 2.5 / ATS)"
  fi
  for k in NSAllowsArbitraryLoadsInWebContent NSAllowsArbitraryLoadsForMedia NSAllowsLocalNetworking; do
    if [ "$(ij ".NSAppTransportSecurity.$k // false")" = "true" ]; then info "INFO: $k=true"; fi
  done
  insecure="$(ij '.NSAppTransportSecurity.NSExceptionDomains // {} | to_entries[] | select(.value.NSExceptionAllowsInsecureHTTPLoads == true or .value.NSTemporaryExceptionAllowsInsecureHTTPLoads == true) | .key')"
  if [ -n "$insecure" ]; then
    flag "WARN: ATS exception domains allowing insecure HTTP: $(printf '%s' "$insecure" | tr '\n' ' ')"
  fi

  info ""
  info "-- UIBackgroundModes --"
  bgm="$(ij '.UIBackgroundModes[]?')"
  if [ -n "$bgm" ]; then
    while IFS= read -r m; do
      case "$m" in
        location) note="needs NSLocationAlwaysAndWhenInUseUsageDescription and a feature that truly needs background location (2.5.4)" ;;
        audio) note="only for audible content the user expects to keep playing (2.5.4)" ;;
        voip) note="must be a real VoIP app using PushKit/CallKit (2.5.4)" ;;
        fetch|processing) note="background tasks; declare BGTaskSchedulerPermittedIdentifiers" ;;
        remote-notification) note="silent push" ;;
        bluetooth-central|bluetooth-peripheral) note="needs NSBluetoothAlwaysUsageDescription" ;;
        external-accessory) note="MFi accessory protocols required" ;;
        *) note="" ;;
      esac
      info "$m${note:+  - $note}"
    done <<< "$bgm"
    if printf '%s\n' "$bgm" | grep -qxE 'fetch|processing' && ! ihas BGTaskSchedulerPermittedIdentifiers; then
      flag "WARN: UIBackgroundModes has fetch/processing but BGTaskSchedulerPermittedIdentifiers is missing"
    fi
    if printf '%s\n' "$bgm" | grep -qx 'location' && ! ihas NSLocationAlwaysAndWhenInUseUsageDescription; then
      flag "POSSIBLE ITMS-90683: background mode 'location' without NSLocationAlwaysAndWhenInUseUsageDescription"
    fi
    for m in audio voip location; do
      if printf '%s\n' "$bgm" | grep -qx "$m"; then
        flag "WARN: UIBackgroundModes includes '$m' - App Review checks that the app actually needs it (Guideline 2.5.4)"
      fi
    done
  else
    info "(none)"
  fi

  info ""
  info "-- UIRequiredDeviceCapabilities --"
  caps="$(ij '(.UIRequiredDeviceCapabilities // []) | if type=="object" then (to_entries|map("\(.key)=\(.value)")) else . end | join(", ")')"
  info "${caps:-(none)}"
  [ -z "$caps" ] || info "INFO: required capabilities can be removed later but not added in updates (it would drop supported devices); keep the list minimal"

  info ""
  info "-- URL schemes (CFBundleURLTypes) --"
  schemes="$(ij '[.CFBundleURLTypes[]?.CFBundleURLSchemes[]?] | join(", ")')"
  info "${schemes:-(none)}"

  info ""
  info "-- LSApplicationQueriesSchemes --"
  qcount="$(ij '(.LSApplicationQueriesSchemes // []) | length')"
  info "count: ${qcount:-0}"
  [ "${qcount:-0}" = 0 ] || info "$(ij '(.LSApplicationQueriesSchemes // []) | join(", ")')"
  if [ "${qcount:-0}" -gt 50 ] 2>/dev/null; then
    flag "WARN: more than 50 LSApplicationQueriesSchemes - iOS ignores entries beyond 50"
  fi

  # iPad multitasking: all four orientations unless the app opts out of multitasking.
  if [ "$(ij '[.UIDeviceFamily[]? | tostring] | index("2") != null')" = "true" ] && [ "$(ij '.UIRequiresFullScreen // false')" != "true" ]; then
    ocount="$(ij '(.["UISupportedInterfaceOrientations~ipad"] // .UISupportedInterfaceOrientations // []) | length')"
    if [ "${ocount:-0}" -lt 4 ]; then
      flag "POSSIBLE ITMS-90474: iPad build supports ${ocount:-0} orientation(s); iPad multitasking expects all four (or UIRequiresFullScreen)"
    fi
  fi
else
  skip "structured Info.plist parsing; raw dump follows"
  plist_raw "$APP/Info.plist"
  if plist_raw "$APP/Info.plist" | grep -A1 'NSAllowsArbitraryLoads' | grep -qiE 'true|=> 1'; then
    flag "WARN: NSAllowsArbitraryLoads appears to be enabled (raw grep)"
  elif LC_ALL=C grep -q 'NSAllowsArbitraryLoads' "$APP/Info.plist"; then
    info "INFO: NSAllowsArbitraryLoads key present (value not determined without a plist parser)"
  fi
fi

APP_NAME="$(basename "$APP")"
[ -n "$EXEC_NAME" ] || EXEC_NAME="${APP_NAME%.app}"
MAIN_BIN="$APP/$EXEC_NAME"

section "MAIN BINARY"
info "path: $(rel "$MAIN_BIN")"
if [ -f "$MAIN_BIN" ]; then
  if [ "$HAVE_LIPO" = 1 ]; then
    info "architectures: $(lipo -archs "$MAIN_BIN" 2>/dev/null || echo unknown)"
  elif [ "$HAVE_FILE" = 1 ]; then
    info "file: $(file -b "$MAIN_BIN" 2>/dev/null | head -c 200)"
  else
    skip "lipo/file: architecture listing"
  fi
  info "size_bytes: $(wc -c < "$MAIN_BIN" | tr -d ' ')"
  if [ -f "$APP/$EXEC_NAME.debug.dylib" ]; then
    flag "WARN: $EXEC_NAME.debug.dylib present - this is a Debug build (ENABLE_DEBUG_DYLIB; app code lives in the dylib), not a release/upload build"
  fi
else
  flag "WARN: main executable not found at $(rel "$MAIN_BIN")"
fi

# ---------------------------------------------------------------------------------------------
# Entitlements + provisioning profiles
# ---------------------------------------------------------------------------------------------
section "ENTITLEMENTS"
ENT="$TMP/entitlements.plist"
: > "$ENT"
ENT_SRC=""
if [ "$HAVE_CODESIGN" = 1 ]; then
  if codesign -d --entitlements - --xml "$APP" > "$ENT" 2>/dev/null && grep -q '<plist' "$ENT"; then
    ENT_SRC="codesign"
  elif codesign -d --entitlements :- "$APP" > "$ENT" 2>/dev/null && grep -q '<plist' "$ENT"; then
    ENT_SRC="codesign"
  fi
fi
if [ -z "$ENT_SRC" ] && [ -f "$MAIN_BIN" ]; then
  # Fallback (no codesign, or simulator build with __entitlements section): the entitlements
  # plist is stored as plain XML inside the binary; take the last plist that is not an Info.plist.
  LC_ALL=C tr -c '[:print:]\t\n' '\n' < "$MAIN_BIN" | awk '
    /<\?xml/ { buf = ""; cap = 1; sub(/^.*<\?xml/, "<?xml") }
    cap { buf = buf $0 "\n" }
    /<\/plist>/ && cap { cap = 0; if (buf ~ /<key>/ && buf !~ /CFBundleIdentifier/) last = buf }
    END { printf "%s", last }' > "$ENT" || true
  if grep -q '<plist' "$ENT"; then
    ENT_SRC="embedded plist in binary"
    [ "$HAVE_CODESIGN" = 1 ] || skip "codesign: entitlements read from the raw binary instead"
  fi
fi
if [ -n "$ENT_SRC" ]; then
  info "source: $ENT_SRC"
  if [ "$STRUCT" = 1 ] && plist_to_json "$ENT" "$TMP/ent.json"; then
    jq -r 'to_entries[] | "\(.key) = \(.value|tojson)"' "$TMP/ent.json" 2>/dev/null || true
  else
    xml_norm "$ENT" | grep -vE '^<(\?xml|!DOCTYPE|plist|/plist|dict|/dict)' || true
  fi
  gta="$(xml_key_value "$ENT" get-task-allow)"
  aps="$(xml_key_value "$ENT" aps-environment)"
  if [ "$gta" = "true" ]; then
    if [ "$INPUT_KIND" = "ipa" ]; then
      flag "WARN: get-task-allow=true - development-signed build; an App Store upload must be distribution-signed"
    else
      info "INFO: get-task-allow=true (development signing). Normal for Debug builds and for archives that are re-signed at export; a problem only if the uploaded .ipa still has it."
    fi
  fi
  if [ "$aps" = "development" ]; then
    if [ "$INPUT_KIND" = "ipa" ]; then
      flag "WARN: aps-environment=development in the .ipa - push will not work in production"
    else
      info "INFO: aps-environment=development (expected before distribution re-signing)"
    fi
  fi
  if grep -q 'com.apple.developer.healthkit' "$ENT" && { [ "$INFO_OK" = 0 ] || ! ihas NSHealthShareUsageDescription; }; then
    flag "POSSIBLE ITMS-90683: HealthKit entitlement present but NSHealthShareUsageDescription missing"
  fi
else
  info "(no entitlements found - unsigned, ad-hoc simulator build, or unreadable)"
fi

section "PROVISIONING PROFILES"
found_prof=0
while IFS= read -r -d '' prof; do
  found_prof=1
  out="$TMP/profile.plist"
  : > "$out"
  if [ "$HAVE_SECURITY" = 1 ] && security cms -D -i "$prof" > "$out" 2>/dev/null && [ -s "$out" ]; then :
  elif [ "$HAVE_OPENSSL" = 1 ] && openssl smime -inform der -verify -noverify -in "$prof" > "$out" 2>/dev/null && [ -s "$out" ]; then :
  else
    # The plist payload is stored unencrypted inside the CMS envelope.
    LC_ALL=C tr -c '[:print:]\t\n' '\n' < "$prof" | sed -n '/<?xml/,/<\/plist>/p' > "$out" || true
  fi
  info "profile: $(rel "$prof")"
  if ! grep -q '<plist' "$out"; then info "  (could not decode)"; continue; fi
  p_gta="$(xml_key_value "$out" get-task-allow)"
  p_aps="$(xml_key_value "$out" aps-environment)"
  p_exp="$(xml_key_value "$out" ExpirationDate)"
  p_all="$(xml_key_value "$out" ProvisionsAllDevices)"
  p_dev="$(xml_norm "$out" | awk '/<key>ProvisionedDevices<\/key>/ { a = 1; next } a && /<\/array>/ { exit } a && /<string>/ { n++ } END { print n + 0 }')"
  if [ "$p_all" = "true" ]; then ptype="enterprise (in-house)"
  elif [ "$p_dev" -gt 0 ] && [ "$p_gta" = "true" ]; then ptype="development"
  elif [ "$p_dev" -gt 0 ]; then ptype="ad-hoc"
  else ptype="app-store (no device list)"; fi
  info "  type: $ptype"
  info "  provisioned_devices: $p_dev"
  info "  get-task-allow: ${p_gta:-unset}"
  info "  aps-environment: ${p_aps:-unset}"
  info "  expiration: ${p_exp:-unknown}"
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if [ -n "$p_exp" ] && [[ "$p_exp" < "$now" ]]; then flag "WARN: provisioning profile $(rel "$prof") expired on $p_exp"; fi
  if [ "$INPUT_KIND" = "ipa" ] && [ "$ptype" != "app-store (no device list)" ]; then
    flag "WARN: .ipa embeds a $ptype provisioning profile ($(rel "$prof")) - App Store uploads need an App Store distribution profile"
  fi
  if [ "$INPUT_KIND" = "ipa" ] && [ "$p_gta" = "true" ]; then
    flag "WARN: provisioning profile $(rel "$prof") allows get-task-allow (debug)"
  fi
done < <(find "$APP" -name '*.mobileprovision' -print0 2>/dev/null)
[ "$found_prof" = 1 ] || info "(no embedded.mobileprovision - normal for simulator and some Debug builds)"

# ---------------------------------------------------------------------------------------------
# Components: main binary, frameworks, dylibs, extensions, watch apps, app clips
# ---------------------------------------------------------------------------------------------
COMP_KIND=(); COMP_NAME=(); COMP_DIR=(); COMP_BIN=()
add_comp() { COMP_KIND+=("$1"); COMP_NAME+=("$2"); COMP_DIR+=("$3"); COMP_BIN+=("$4"); }

# bundle_exec <bundle-dir> : path of the bundle's executable
bundle_exec() {
  local d="$1" exe="" j="$TMP/bundle.json"
  if [ -f "$d/Info.plist" ] && [ "$STRUCT" = 1 ] && plist_to_json "$d/Info.plist" "$j"; then
    exe="$(jq -r '.CFBundleExecutable // empty' "$j" 2>/dev/null || true)"
  fi
  if [ -z "$exe" ]; then exe="$(basename "$d")"; exe="${exe%.*}"; fi
  printf '%s/%s' "$d" "$exe"
}
bundle_key() { # <bundle-dir> <jq-filter>
  local j="$TMP/bundle.json"
  if [ -f "$1/Info.plist" ] && [ "$STRUCT" = 1 ] && plist_to_json "$1/Info.plist" "$j"; then
    jq -r "$2" "$j" 2>/dev/null || true
  fi
}

add_comp main "$EXEC_NAME" "$APP" "$MAIN_BIN"
# Xcode 16+ Debug builds move the app's code into <exec>.debug.dylib (the executable is a stub).
if [ -f "$APP/$EXEC_NAME.debug.dylib" ]; then
  add_comp main "$EXEC_NAME.debug.dylib" "$APP" "$APP/$EXEC_NAME.debug.dylib"
fi
for d in "$APP"/Frameworks/*.framework; do
  [ -d "$d" ] || continue
  n="$(basename "$d")"; add_comp framework "${n%.framework}" "$d" "$(bundle_exec "$d")"
done
for f in "$APP"/Frameworks/*.dylib; do
  [ -f "$f" ] || continue
  n="$(basename "$f")"
  case "$n" in libswift*) continue ;; esac   # Swift runtime copies (old deployment targets)
  add_comp dylib "${n%.dylib}" "$(dirname "$f")" "$f"
done
for d in "$APP"/PlugIns/*.appex "$APP"/Extensions/*.appex; do
  [ -d "$d" ] || continue
  n="$(basename "$d")"; add_comp appex "${n%.appex}" "$d" "$(bundle_exec "$d")"
done
for d in "$APP"/Watch/*.app "$APP"/AppClips/*.app; do
  [ -d "$d" ] || continue
  n="$(basename "$d")"; add_comp nested-app "${n%.app}" "$d" "$(bundle_exec "$d")"
done
NCOMP="${#COMP_KIND[@]}"

# Build symbol files once (reused by every symbol-based check below).
SYMDIR="$TMP/sym"; mkdir -p "$SYMDIR"
i=0
while [ "$i" -lt "$NCOMP" ]; do
  make_symfile "${COMP_BIN[$i]}" "$SYMDIR/$i.txt"
  i=$((i + 1))
done

# Privacy manifests belonging to a component (framework/appex: inside its bundle, up to nested
# resource bundles; main: the app root manifest only).
comp_manifests() {
  local idx="$1"
  case "${COMP_KIND[$idx]}" in
    main) [ -f "$APP/PrivacyInfo.xcprivacy" ] && printf '%s\n' "$APP/PrivacyInfo.xcprivacy" || true ;;
    dylib) : ;;
    *)
      # Skip manifests of bundles nested inside this one (e.g. an appex's own Frameworks/).
      local d="${COMP_DIR[$idx]}" p
      find "$d" -maxdepth 3 -name PrivacyInfo.xcprivacy 2>/dev/null | while IFS= read -r p; do
        case "${p#"$d"/}" in Frameworks/*|PlugIns/*|Extensions/*) ;; *) printf '%s\n' "$p" ;; esac
      done || true ;;
  esac
}

# manifest_cats <xcprivacy> : declared category short names, one per line.
manifest_cats() {
  local j="$TMP/m.json"
  if [ "$STRUCT" = 1 ] && plist_to_json "$1" "$j"; then
    jq -r '.NSPrivacyAccessedAPITypes[]?.NSPrivacyAccessedAPIType // empty' "$j" 2>/dev/null | sed 's/^NSPrivacyAccessedAPICategory//' || true
  else
    grep -oE 'NSPrivacyAccessedAPICategory[A-Za-z]+' "$1" 2>/dev/null | sed 's/^NSPrivacyAccessedAPICategory//' | sort -u || true
  fi
}

section "EMBEDDED COMPONENTS"
info "format: kind | name | version | privacy_manifest | on_apple_sdk_list | binary"
i=0
while [ "$i" -lt "$NCOMP" ]; do
  k="${COMP_KIND[$i]}"; n="${COMP_NAME[$i]}"; d="${COMP_DIR[$i]}"
  ver="-"
  if [ "$k" != dylib ] && [ "$k" != main ]; then
    ver="$(bundle_key "$d" '.CFBundleShortVersionString // "-"')"; ver="${ver:--}"
  fi
  if [ "$k" = dylib ]; then pm="n/a(dylib)"
  elif [ -n "$(comp_manifests "$i")" ]; then pm="yes"
  else pm="no"; fi
  if canon="$(sdk_canonical "$n")"; then onlist="yes($canon)"; else onlist="no"; fi
  bin_state="ok"; [ -f "${COMP_BIN[$i]}" ] || bin_state="missing"
  info "$k | $n | $ver | $pm | $onlist | $bin_state"
  if [ "$k" = appex ]; then
    ep="$(bundle_key "$d" '.NSExtension.NSExtensionPointIdentifier // .EXAppExtensionAttributes.EXExtensionPointIdentifier // "-"')"
    info "    extension_point: ${ep:--}"
  fi
  i=$((i + 1))
done
info ""
info "-- resource bundles at app root (static SDKs ship their privacy manifests here) --"
root_bundles=0
for bdir in "$APP"/*.bundle; do
  [ -d "$bdir" ] || continue
  root_bundles=1
  if find "$bdir" -maxdepth 2 -name PrivacyInfo.xcprivacy 2>/dev/null | grep -q .; then bpm="privacy_manifest=yes"; else bpm="privacy_manifest=no"; fi
  info "$(basename "$bdir") | $bpm"
done
[ "$root_bundles" = 1 ] || info "(none)"

# ---------------------------------------------------------------------------------------------
# Privacy manifests (all of them)
# ---------------------------------------------------------------------------------------------
section "PRIVACY MANIFESTS"
ALL_MANIFESTS="$TMP/manifests.txt"
find "$APP" -name PrivacyInfo.xcprivacy 2>/dev/null | sort > "$ALL_MANIFESTS" || true
if [ ! -f "$APP/PrivacyInfo.xcprivacy" ]; then
  info "INFO: no app-level PrivacyInfo.xcprivacy at the bundle root (needed when the app or its static libraries use required-reason APIs or collect data; see the next sections)"
fi
if [ ! -s "$ALL_MANIFESTS" ]; then
  info "(no PrivacyInfo.xcprivacy files found anywhere in the bundle)"
fi
AGG="$TMP/agg"; mkdir -p "$AGG"; : > "$AGG/cats"; : > "$AGG/domains"; : > "$AGG/collected"; : > "$AGG/tracking"
while IFS= read -r m; do
  [ -n "$m" ] || continue
  info "manifest: $(rel "$m")"
  j="$TMP/m.json"
  if [ "$STRUCT" = 1 ] && plist_to_json "$m" "$j"; then
    tr_="$(jq -r 'if has("NSPrivacyTracking") then (.NSPrivacyTracking|tostring) else "unset" end' "$j")"
    doms="$(jq -r '(.NSPrivacyTrackingDomains // []) | join(", ")' "$j")"
    info "  NSPrivacyTracking: $tr_"
    info "  NSPrivacyTrackingDomains: ${doms:-(none)}"
    echo "$tr_" >> "$AGG/tracking"
    jq -r '.NSPrivacyTrackingDomains[]?' "$j" >> "$AGG/domains" 2>/dev/null || true
    if [ "$tr_" = "true" ] && [ -z "$doms" ]; then info "  INFO: tracking=true with no tracking domains"; fi
    apis="$(jq -r '.NSPrivacyAccessedAPITypes[]? | "\(.NSPrivacyAccessedAPIType // "?" | sub("^NSPrivacyAccessedAPICategory";"")): \((.NSPrivacyAccessedAPITypeReasons // []) | join(","))"' "$j" 2>/dev/null || true)"
    info "  accessed_api_types:"
    if [ -n "$apis" ]; then
      while IFS= read -r line; do
        info "    $line"
        c="${line%%:*}"; rs="${line#*: }"
        for r in $(printf '%s' "$rs" | tr ',' ' '); do printf '%s\t%s\n' "$c" "$r" >> "$AGG/cats"; done
        [ -n "$rs" ] || printf '%s\t(no reason)\n' "$c" >> "$AGG/cats"
        valid="$(cat_reasons "$c")"
        if [ -z "$valid" ]; then
          flag "WARN: $(rel "$m") declares unknown API category '$c'"
        elif [ -z "$rs" ]; then
          flag "WARN: $(rel "$m") declares $c without any NSPrivacyAccessedAPITypeReasons"
        else
          for r in $(printf '%s' "$rs" | tr ',' ' '); do
            case " $valid " in *" $r "*) ;; *) flag "WARN: $(rel "$m") uses reason '$r' which is not an approved reason for $c" ;; esac
          done
        fi
      done <<< "$apis"
    else
      info "    (none)"
    fi
    col="$(jq -r '.NSPrivacyCollectedDataTypes[]? | "\(.NSPrivacyCollectedDataType // "?" | sub("^NSPrivacyCollectedDataType";"")) linked=\(.NSPrivacyCollectedDataTypeLinked) tracking=\(.NSPrivacyCollectedDataTypeTracking) purposes=\((.NSPrivacyCollectedDataTypePurposes // []) | map(sub("^NSPrivacyCollectedDataTypePurpose";"")) | join(","))"' "$j" 2>/dev/null || true)"
    info "  collected_data_types:"
    if [ -n "$col" ]; then
      printf '%s\n' "$col" | sed 's/^/    /'
      printf '%s\n' "$col" | sed 's/ .*//' >> "$AGG/collected"
    else
      info "    (none)"
    fi
  else
    cats="$(manifest_cats "$m" | tr '\n' ' ')"
    info "  accessed_api_categories (grep): ${cats:-(none)}"
    for c in $cats; do printf '%s\t?\n' "$c" >> "$AGG/cats"; done
  fi
done < "$ALL_MANIFESTS"

info ""
info "-- aggregated across all manifests --"
info "categories (with reasons):"
if [ -s "$AGG/cats" ]; then
  sort -u "$AGG/cats" | awk -F'\t' '{ r[$1] = (r[$1] == "" ? $2 : r[$1] "," $2) } END { for (c in r) print "  " c ": " r[c] }' | sort
else
  info "  (none)"
fi
info "tracking_true_in_any: $(grep -qx true "$AGG/tracking" && echo yes || echo no)"
info "tracking_domains: $(sort -u "$AGG/domains" | tr '\n' ' ')"
info "collected_data_types: $(sort -u "$AGG/collected" | tr '\n' ' ')"
if grep -qx true "$AGG/tracking" && [ "$INFO_OK" = 1 ] && ! ihas NSUserTrackingUsageDescription; then
  flag "WARN: a privacy manifest sets NSPrivacyTracking=true but Info.plist has no NSUserTrackingUsageDescription (ATT prompt needed before tracking)"
fi

# Declared categories for the app level: root manifest + root-level resource bundles
# (statically linked SDKs). Apple aggregates these into the app's privacy report.
APP_DECLARED=""
if [ -f "$APP/PrivacyInfo.xcprivacy" ]; then APP_DECLARED="$APP_DECLARED $(manifest_cats "$APP/PrivacyInfo.xcprivacy" | tr '\n' ' ')"; fi
ROOT_BUNDLE_DECLARED=""
for bm in "$APP"/*.bundle/PrivacyInfo.xcprivacy "$APP"/*.bundle/*/PrivacyInfo.xcprivacy; do
  [ -f "$bm" ] || continue
  ROOT_BUNDLE_DECLARED="$ROOT_BUNDLE_DECLARED $(manifest_cats "$bm" | tr '\n' ' ')"
done
in_set() { case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# ---------------------------------------------------------------------------------------------
# Required-reason API usage (heuristic) -> POSSIBLE ITMS-91053
# ---------------------------------------------------------------------------------------------
section "REQUIRED-REASON API USAGE (HEURISTIC)"
info "Method: nm -u + strings of each binary matched against Apple's required-reason API list."
info "A hit means the symbol/selector is referenced, not that the code path runs."
i=0
while [ "$i" -lt "$NCOMP" ]; do
  k="${COMP_KIND[$i]}"; n="${COMP_NAME[$i]}"; sym="$SYMDIR/$i.txt"
  info ""
  info "[$k] $n ($(rel "${COMP_BIN[$i]}"))"
  if [ ! -s "$sym" ]; then info "  (binary missing or unreadable)"; i=$((i + 1)); continue; fi
  own=""
  while IFS= read -r m; do
    [ -n "$m" ] || continue
    own="$own $(manifest_cats "$m" | tr '\n' ' ')"
  done < <(comp_manifests "$i")
  any=0
  for c in $CATEGORIES; do
    ev="$(grep -Eo "$(cat_pattern "$c")" "$sym" 2>/dev/null | sort -u | head -n 4 | tr '\n' ' ' || true)"
    ev="${ev% }"
    [ -n "$ev" ] || continue
    any=1
    if in_set "$c" "$own"; then
      info "  $c: referenced ($ev) - declared in own manifest"
    elif [ "$k" = main ] && in_set "$c" "$APP_DECLARED $ROOT_BUNDLE_DECLARED"; then
      info "  $c: referenced ($ev) - declared at app level"
    elif [ "$k" = dylib ]; then
      info "  $c: referenced ($ev) - plain dylib cannot carry a manifest; the app manifest must cover it"
      if ! in_set "$c" "$APP_DECLARED $ROOT_BUNDLE_DECLARED"; then
        flag "POSSIBLE ITMS-91053: $n.dylib references NSPrivacyAccessedAPICategory$c APIs ($ev) and the app manifest does not declare it"
      fi
    elif in_set "$c" "$APP_DECLARED $ROOT_BUNDLE_DECLARED"; then
      # Declaring a third-party binary's API use in the app's own manifest is the usual
      # workaround and is generally accepted, so this is not flagged.
      info "  $c: referenced ($ev) - not in this bundle's own manifest, but declared at app level (usually accepted; the SDK should ideally ship its own)"
    else
      info "  $c: referenced ($ev) - NOT declared"
      flag "POSSIBLE ITMS-91053: $k '$n' references NSPrivacyAccessedAPICategory$c APIs ($ev) but no applicable privacy manifest declares this category"
    fi
  done
  [ "$any" = 1 ] || info "  (no required-reason API signals)"
  i=$((i + 1))
done

# ---------------------------------------------------------------------------------------------
# Apple's privacy-impacting SDK list -> POSSIBLE ITMS-91061
# ---------------------------------------------------------------------------------------------
section "THIRD-PARTY SDKS ON APPLE'S PRIVACY-IMPACTING LIST"
info "List embedded in this script (verify against Apple's current 'third-party SDK requirements' page)."
info "Note: SDK signatures cannot be verified from a built app (frameworks are re-signed with the app)."
# bundle_sdk_candidates <bundle-basename-without-.bundle> : names to try against the list.
bundle_sdk_candidates() {
  local bn="$1"
  printf '%s\n' "$bn" "${bn%_Privacy}" "${bn%_privacy}" "${bn%Privacy}" "${bn%%_*}" "${bn#*_}" "${bn%_resources}"
}
# root_bundle_has_manifest_for <ListName>
root_bundle_has_manifest_for() {
  local bdir cnd canon
  for bdir in "$APP"/*.bundle; do
    [ -d "$bdir" ] || continue
    while IFS= read -r cnd; do
      canon="$(sdk_canonical "$cnd")" || continue
      if [ "$canon" = "$1" ] && find "$bdir" -maxdepth 2 -name PrivacyInfo.xcprivacy 2>/dev/null | grep -q .; then return 0; fi
    done < <(bundle_sdk_candidates "$(basename "$bdir" .bundle)")
  done
  return 1
}
HANDLED=" "
# 1) dynamic frameworks
i=0
while [ "$i" -lt "$NCOMP" ]; do
  if [ "${COMP_KIND[$i]}" = framework ] && canon="$(sdk_canonical "${COMP_NAME[$i]}")"; then
    HANDLED="$HANDLED$canon "
    if [ -n "$(comp_manifests "$i")" ]; then
      info "OK: $canon (${COMP_NAME[$i]}.framework) ships PrivacyInfo.xcprivacy"
    elif root_bundle_has_manifest_for "$canon"; then
      info "OK: $canon (${COMP_NAME[$i]}.framework) - privacy manifest in an app-root resource bundle"
    else
      flag "POSSIBLE ITMS-91061: ${COMP_NAME[$i]}.framework ($canon) is on Apple's list but ships no PrivacyInfo.xcprivacy - update the SDK to a version that includes one"
    fi
  fi
  i=$((i + 1))
done
# 2) resource bundles at the root (CocoaPods "<Pod>_Privacy.bundle", SPM "<Package>_<Target>.bundle")
BUNDLE_SDKS=" "
for bdir in "$APP"/*.bundle; do
  [ -d "$bdir" ] || continue
  while IFS= read -r cnd; do
    if canon="$(sdk_canonical "$cnd")"; then
      if find "$bdir" -maxdepth 2 -name PrivacyInfo.xcprivacy 2>/dev/null | grep -q .; then
        BUNDLE_SDKS="$BUNDLE_SDKS$canon "
        if ! in_set "$canon" "$HANDLED"; then info "OK: $canon privacy manifest via resource bundle $(basename "$bdir")"; HANDLED="$HANDLED$canon "; fi
      fi
      break
    fi
  done < <(bundle_sdk_candidates "$(basename "$bdir" .bundle)")
done
# 3) statically linked SDKs detected by markers in the main binary (lower confidence).
# Only strings that are NOT imported symbols count: a class imported from a dynamic framework
# shows up as an undefined symbol, a statically linked one as a defined class/type name.
cut -f1 "$STATIC_MARKERS" > "$TMP/marker-tokens.txt"
: > "$TMP/marker-hits.txt"
i=0
while [ "$i" -lt "$NCOMP" ]; do
  if [ "${COMP_KIND[$i]}" = main ] && [ -s "$SYMDIR/$i.txt.str" ]; then
    grep -F -f "$TMP/marker-tokens.txt" "$SYMDIR/$i.txt.str" 2>/dev/null | grep -vxF -f "$SYMDIR/$i.txt.nm" 2>/dev/null |
      grep -oF -f "$TMP/marker-tokens.txt" >> "$TMP/marker-hits.txt" || true
  fi
  i=$((i + 1))
done
[ "$HAVE_NM" = 1 ] || info "INFO: without nm, imported and statically linked classes cannot be told apart (more false positives)"
# Names of all embedded frameworks, to skip SDKs that are really dynamic (e.g. OneSignalCore).
FW_NAMES=" "
i=0
while [ "$i" -lt "$NCOMP" ]; do
  [ "${COMP_KIND[$i]}" = framework ] && FW_NAMES="$FW_NAMES$(lower "${COMP_NAME[$i]}") "
  i=$((i + 1))
done
sort -u "$TMP/marker-hits.txt" -o "$TMP/marker-hits.txt"
if [ -s "$TMP/marker-hits.txt" ]; then
  while IFS= read -r tok; do
    [ -n "$tok" ] || continue
    sdk="$(awk -F'\t' -v t="$tok" '$1 == t { print $2; exit }' "$STATIC_MARKERS")"
    [ -n "$sdk" ] || continue
    in_set "$sdk" "$HANDLED" && continue
    case "$FW_NAMES" in *" $(lower "$sdk")"*) continue ;; esac
    HANDLED="$HANDLED$sdk "
    if in_set "$sdk" "$BUNDLE_SDKS"; then
      info "OK: $sdk (static, marker '$tok') has a privacy-manifest resource bundle"
    else
      flag "POSSIBLE ITMS-91061: $sdk appears statically linked into the main binary (marker '$tok', low confidence) and no matching privacy-manifest resource bundle was found"
    fi
  done < "$TMP/marker-hits.txt"
fi
[ "$HANDLED" != " " ] || info "(no SDKs from Apple's list detected)"

# ---------------------------------------------------------------------------------------------
# Purpose strings vs APIs referenced in binaries -> POSSIBLE ITMS-90683
# ---------------------------------------------------------------------------------------------
section "PURPOSE STRINGS VS REFERENCED APIS (HEURISTIC)"
if [ "$INFO_OK" = 1 ]; then
  cut -f1 "$USAGE_MARKERS" > "$TMP/usage-tokens.txt"
  : > "$TMP/usage-hits.tsv"
  i=0
  while [ "$i" -lt "$NCOMP" ]; do
    if [ -s "$SYMDIR/$i.txt" ]; then
      grep -xF -f "$TMP/usage-tokens.txt" "$SYMDIR/$i.txt" 2>/dev/null | sort -u | while IFS= read -r tok; do
        printf '%s\t%s\n' "$tok" "${COMP_NAME[$i]}"
      done >> "$TMP/usage-hits.tsv" || true
    fi
    i=$((i + 1))
  done
  if [ -s "$TMP/usage-hits.tsv" ]; then
    while IFS="$(printf '\t')" read -r tok keys; do
      where="$(awk -F'\t' -v t="$tok" '$1 == t { print $2 }' "$TMP/usage-hits.tsv" | sort -u | tr '\n' ',' | sed 's/,$//')"
      [ -n "$where" ] || continue
      ok=""
      for key in $(printf '%s' "$keys" | tr '|' ' '); do
        if ihas "$key"; then ok="$key"; break; fi
      done
      if [ -n "$ok" ]; then
        info "OK: $tok (in $where) -> $ok present"
      else
        flag "POSSIBLE ITMS-90683: $tok referenced in $where but Info.plist lacks $(printf '%s' "$keys" | sed 's/|/ or /g')"
      fi
    done < "$USAGE_MARKERS"
  else
    info "(no permission-gated API markers found)"
  fi
else
  skip "purpose-string cross-check (needs structured Info.plist parsing)"
fi

# ---------------------------------------------------------------------------------------------
# Other flags
# ---------------------------------------------------------------------------------------------
section "OTHER FLAGS"
# Scan sources for URLs: all component symbol files + JS bundles (React Native / Hermes).
URLSRC="$TMP/urlsrc.txt"
cat "$SYMDIR"/*.txt > "$URLSRC" 2>/dev/null || true
for js in "$APP"/*.jsbundle "$APP"/assets/*.bundle; do
  [ -f "$js" ] || continue
  extract_strings "$js" >> "$URLSRC"
done

info "-- linked libraries (main binary) --"
if [ ! -f "$MAIN_BIN" ]; then
  info "  (main executable missing)"
elif [ "$HAVE_OTOOL" = 1 ]; then
  otool -L "$MAIN_BIN" 2>/dev/null | tail -n +2 | sed -E 's/^[[:space:]]+//; s/ \(compatibility.*//' | sort -u | grep -vE '^/(System/Library|usr/lib)/' | sed 's/^/  /' || true
  info "  (system frameworks/libs omitted)"
else
  skip "otool: linked library list"
fi

info "-- private framework references --"
priv="$(grep -ohE '/System/Library/PrivateFrameworks/[A-Za-z0-9_.+-]+' "$URLSRC" 2>/dev/null | sort -u || true)"
if [ -n "$priv" ]; then
  printf '%s\n' "$priv" | sed 's/^/  /'
  flag "WARN: binary strings reference private framework paths ($(printf '%s' "$priv" | wc -l | tr -d ' ') unique) - private API use is rejected under 2.5.1 (verify they are actually loaded)"
else
  info "  (none)"
fi

info "-- dynamic loading (dlopen/dlsym) --"
i=0; dl=0
while [ "$i" -lt "$NCOMP" ]; do
  if grep -qxE '_dlopen|_dlsym' "$SYMDIR/$i.txt" 2>/dev/null; then info "  ${COMP_KIND[$i]} ${COMP_NAME[$i]}: references dlopen/dlsym"; dl=1; fi
  i=$((i + 1))
done
if [ "$dl" = 1 ]; then
  info "  INFO: common in runtimes/SDKs; only a problem if used to load code not in the bundle (2.5.2)"
else
  info "  (none)"
fi

info "-- hardcoded http:// URLs (top 10 by occurrences) --"
# Exclude well-known non-network identifiers (XML namespaces, DTDs, certificate URLs).
grep -ohE 'http://[A-Za-z0-9._~:/?#@!$&*+,;=%-]+' "$URLSRC" 2>/dev/null |
  grep -vE '^http://(www\.w3\.org|www\.apple\.com/(DTDs|appleca|certificateauthority)|ns\.adobe\.com|purl\.org|schemas\.|xml\.|json-schema\.org|iptc\.org|crl\.|ocsp\.|www\.example\.(com|org)|example\.(com|org)|www\.opengis\.net|ns\.useplus\.org|cipa\.jp|www\.xfa\.org|xmlpull\.org|apache\.org/xml)' \
  > "$TMP/http.txt" || true
info "  unique_http_urls: $(sort -u "$TMP/http.txt" | wc -l | tr -d ' ')"
sort "$TMP/http.txt" | uniq -c | sort -rn | head -n 10 | sed -E 's/^[[:space:]]*/  /' || true
if [ -s "$TMP/http.txt" ]; then
  info "  INFO: plain-HTTP endpoints need ATS exceptions; check none carry user data"
fi

info "-- localhost / staging-looking hosts (top 10) --"
grep -ohE '(https?|wss?)://[A-Za-z0-9._-]+' "$URLSRC" 2>/dev/null | sed -E 's#^[a-z]+://##' | tr '[:upper:]' '[:lower:]' |
  grep -E '^(localhost|127\.|0\.0\.0\.0|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)|\.(local|test|internal|localhost)$|(^|[.-])(staging|stage|stg|dev|develop|qa|uat|preprod|sandbox)[.-]|ngrok' \
  > "$TMP/hosts.txt" || true
if [ -s "$TMP/hosts.txt" ]; then
  sort "$TMP/hosts.txt" | uniq -c | sort -rn | head -n 10 | sed -E 's/^[[:space:]]*/  /'
  flag "WARN: binary references localhost/staging-looking hosts ($(sort -u "$TMP/hosts.txt" | wc -l | tr -d ' ') unique) - make sure release builds do not point at test backends (2.1 completeness)"
else
  info "  (none)"
fi

# ---------------------------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------------------------
section "SUMMARY"
n91053="$(grep -c '^POSSIBLE ITMS-91053:' "$FLAGS" || true)"
n91061="$(grep -c '^POSSIBLE ITMS-91061:' "$FLAGS" || true)"
nposs="$(grep -c '^POSSIBLE ITMS-' "$FLAGS" || true)"
nwarn="$(grep -c '^WARN:' "$FLAGS" || true)"
info "components_scanned: $NCOMP"
info "possible_itms_total: $nposs (91053: $n91053, 91061: $n91061)"
info "warnings: $nwarn"
info "skipped_checks: $(wc -l < "$SKIPS" | tr -d ' ')"
if [ -s "$FLAGS" ]; then
  info ""
  info "-- findings --"
  awk '!seen[$0]++' "$FLAGS"
fi
if [ -s "$SKIPS" ]; then
  info ""
  info "-- skipped --"
  awk '!seen[$0]++' "$SKIPS"
fi
exit 0
