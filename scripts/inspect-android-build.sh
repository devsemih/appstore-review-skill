#!/usr/bin/env bash
#
# inspect-android-build.sh - read-only inspection of a built Android app (.aab or .apk) for
# Google Play submission problems that only show up in the final artifact: the MERGED manifest
# (including permissions and components added by SDKs), targetSdkVersion, debuggable/cleartext
# flags, foreground-service types, exported components, ad/analytics/attribution SDKs,
# 64-bit and 16 KB page-size readiness of native libraries.
#
# Output: plain text, stable "=== SECTION ===" headings. Line prefixes:
#   POSSIBLE PLAY REJECTION:  upload blocked or policy enforcement likely (verify)
#   WARN:                     restricted permission / policy declaration needed / risky setting
#   INFO:                     context only
#   SKIPPED:                  an optional tool was missing, so a check did not run
# All findings are repeated in the final "=== SUMMARY ===" section.
#
# SDK detection and string-based fallbacks are HEURISTICS (R8 can rename classes; strings do
# not prove a code path runs). Treat findings as leads to verify, not verdicts.
#
# No network access, nothing is installed, the input is never modified (members are extracted
# into a temp dir that is removed on exit).
#
# Tools (searched in PATH, then $ANDROID_HOME / $ANDROID_SDK_ROOT / ~/Library/Android/sdk /
# ~/Android/Sdk build-tools, cmdline-tools and NDK):
#   required:  unzip, od, awk
#   AAB manifest:  bundletool (or $BUNDLETOOL_JAR + java); fallback aapt2 on the proto manifest
#   APK manifest:  aapt2 (dump xmltree) or apkanalyzer (manifest print)
#   optional:      zipalign (APK 16 KB zip alignment), apksigner (APK signer), strings
# ELF LOAD-segment alignment (16 KB page size) is read directly with od(1); no readelf needed.
#
# Exit codes: 0 = inspection ran (findings are not errors); 2 = bad usage or input;
#             3 = a required tool is missing.

set -euo pipefail
export LC_ALL=C

PROG="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $PROG <path-to .aab | .apk>

Read-only inspection of a built Android app for Google Play submission problems
(merged-manifest permissions, targetSdk, debuggable, cleartext traffic, exported
components, foreground-service types, ads/analytics SDKs, 64-bit / 16 KB native libs).

Options:
  -h, --help    Show this help and exit.

Environment:
  ANDROID_HOME / ANDROID_SDK_ROOT   Android SDK location (to find aapt2, zipalign, ...)
  BUNDLETOOL_JAR                    path to bundletool-all.jar if bundletool is not in PATH

Exit codes: 0 inspection ran (findings are not errors), 2 bad input, 3 missing required tool.
EOF
}

die() { printf '%s: error: %s\n' "$PROG" "$1" >&2; exit "${2:-2}"; }

# ---------------------------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------------------------
if [ "$#" -ne 1 ]; then usage >&2; exit 2; fi
case "$1" in
  -h|--help) usage; exit 0 ;;
  -*) usage >&2; exit 2 ;;
esac
INPUT="$1"
[ -e "$INPUT" ] || die "no such file: $INPUT"
[ -f "$INPUT" ] || die "not a regular file: $INPUT"
case "$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')" in
  *.aab) KIND="aab" ;;
  *.apk) KIND="apk" ;;
  *) die "unsupported input (expected .aab or .apk): $INPUT" ;;
esac

# ---------------------------------------------------------------------------------------------
# Tool discovery
# ---------------------------------------------------------------------------------------------
OS="$(uname -s)"
CLT_OK=1
if [ "$OS" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then CLT_OK=0; fi
have() {
  local p
  p="$(command -v "$1" 2>/dev/null)" || return 1
  # macOS /usr/bin stubs that would pop an "install Command Line Tools" dialog.
  if [ "$OS" = "Darwin" ] && [ "$CLT_OK" = 0 ]; then
    case "$p" in /usr/bin/strings|/usr/bin/objdump) return 1 ;; esac
  fi
  return 0
}

for t in unzip od awk; do have "$t" || die "$t is required" 3; done

SDK_DIRS=()
for d in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
  [ -n "$d" ] && [ -d "$d" ] && SDK_DIRS+=("$d")
done

# find_tool <name> : absolute path of a tool from PATH or the Android SDK, or empty.
find_tool() {
  local name="$1" sdk bt cand
  if have "$name"; then command -v "$name"; return 0; fi
  for sdk in ${SDK_DIRS[@]+"${SDK_DIRS[@]}"}; do
    if [ -d "$sdk/build-tools" ]; then
      # newest build-tools version first
      for bt in $(ls -1 "$sdk/build-tools" 2>/dev/null | sort -t. -k1,1nr -k2,2nr -k3,3nr); do
        if [ -x "$sdk/build-tools/$bt/$name" ]; then printf '%s\n' "$sdk/build-tools/$bt/$name"; return 0; fi
      done
    fi
    for cand in "$sdk/cmdline-tools/latest/bin/$name" "$sdk"/cmdline-tools/*/bin/"$name" "$sdk/tools/bin/$name" \
                "$sdk"/ndk/*/toolchains/llvm/prebuilt/*/bin/"$name"; do
      if [ -x "$cand" ]; then printf '%s\n' "$cand"; return 0; fi
    done
  done
  return 0
}

AAPT2="$(find_tool aapt2)"
APKANALYZER="$(find_tool apkanalyzer)"
ZIPALIGN="$(find_tool zipalign)"
APKSIGNER="$(find_tool apksigner)"
HAVE_STRINGS=0; have strings && HAVE_STRINGS=1
HAVE_JAVA=0; have java && HAVE_JAVA=1
BUNDLETOOL=()
if have bundletool; then
  BUNDLETOOL=(bundletool)
elif [ -n "${BUNDLETOOL_JAR:-}" ] && [ -f "$BUNDLETOOL_JAR" ] && [ "$HAVE_JAVA" = 1 ]; then
  BUNDLETOOL=(java -jar "$BUNDLETOOL_JAR")
fi

# ---------------------------------------------------------------------------------------------
# Temp dir + output helpers
# ---------------------------------------------------------------------------------------------
TMP="$(mktemp -d "${TMPDIR:-/tmp}/inspect-android.XXXXXX")"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
trap 'exit 130' INT TERM

FLAGS="$TMP/flags.txt"; : > "$FLAGS"
SKIPS="$TMP/skips.txt"; : > "$SKIPS"
section() { printf '\n=== %s ===\n' "$1"; }
info()    { printf '%s\n' "$*"; }
flag()    { printf '%s\n' "$*"; printf '%s\n' "$*" >> "$FLAGS"; }
skip()    { printf 'SKIPPED: %s\n' "$*"; printf 'SKIPPED: %s\n' "$*" >> "$SKIPS"; }

# extract_strings : printable strings from stdin (strings(1) when available, tr fallback).
# NULs are dropped first so UTF-16 string pools (binary XML) become readable too.
extract_strings() {
  if [ "$HAVE_STRINGS" = 1 ]; then
    # strings(1) stdin handling differs between BSD/GNU, so go through a temp file.
    cat > "$TMP/strings.bin"
    strings -a "$TMP/strings.bin" 2>/dev/null || true
    rm -f "$TMP/strings.bin"
  else
    tr -c '[:print:]' '\n' | grep -E '.{4,}' || true
  fi
}

# Zip listing (member names only).
LIST="$TMP/list.txt"
unzip -Z1 "$INPUT" > "$LIST" 2>/dev/null || die "could not read zip (not a valid $KIND?): $INPUT"
[ -s "$LIST" ] || die "empty archive: $INPUT"
if [ "$KIND" = "aab" ]; then
  grep -q '^base/manifest/AndroidManifest.xml$' "$LIST" || die "no base/manifest/AndroidManifest.xml - not an Android App Bundle?"
else
  grep -q '^AndroidManifest.xml$' "$LIST" || die "no AndroidManifest.xml - not an APK?"
fi

# Play's target API level requirement for new apps AND updates: API 35 since 2025-08-31,
# API 36 since 2026-08-31 (Wear OS / TV / Automotive have their own schedules).
# UPDATE THIS CONSTANT when Google raises the requirement.
PLAY_TARGET_SDK=36
PLAY_TARGET_SDK_PREV=35

# ---------------------------------------------------------------------------------------------
# Header + tools
# ---------------------------------------------------------------------------------------------
printf 'inspect-android-build report\n'
printf 'input_type: %s\n' "$KIND"
printf 'file: %s\n' "$(basename "$INPUT")"
printf 'size_bytes: %s\n' "$(wc -c < "$INPUT" | tr -d ' ')"
printf 'generated: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
info "NOTE: SDK detection and string fallbacks are heuristics; verify each finding before acting on it."

section "TOOLS"
tool_line() { if [ -n "$2" ]; then printf '%-12s %s\n' "$1" "$2"; else printf '%-12s missing\n' "$1"; fi; }
tool_line bundletool "${BUNDLETOOL[*]:-}"
tool_line aapt2 "$AAPT2"
tool_line apkanalyzer "$APKANALYZER"
tool_line zipalign "$ZIPALIGN"
tool_line apksigner "$APKSIGNER"
tool_line strings "$( [ "$HAVE_STRINGS" = 1 ] && command -v strings || true)"
tool_line java "$( [ "$HAVE_JAVA" = 1 ] && command -v java || true)"

# ---------------------------------------------------------------------------------------------
# Manifest -> flat records "id<TAB>parent<TAB>tag<TAB>key=value<TAB>..."
# ---------------------------------------------------------------------------------------------
MANIFEST_TXT="$TMP/manifest.txt"
FLAT="$TMP/flat.tsv"
MANIFEST_SRC=""

# XML text (bundletool / apkanalyzer) -> flat records. Handles attributes over several lines.
flatten_xml() {
  awk '
    { s = s " " $0 }
    END {
      depth = 0; stack[0] = 0; id = 0
      while ((i = index(s, "<")) > 0) {
        s = substr(s, i + 1); j = index(s, ">"); if (!j) break
        tag = substr(s, 1, j - 1); s = substr(s, j + 1)
        if (tag ~ /^[?!]/) continue
        if (tag ~ /^\//) { if (depth > 0) depth--; continue }
        selfclose = (tag ~ /\/[ \t]*$/); sub(/\/[ \t]*$/, "", tag)
        sub(/^[ \t]+/, "", tag)
        match(tag, /^[^ \t]+/); name = substr(tag, 1, RLENGTH); rest = substr(tag, RLENGTH + 1)
        id++; out = id "\t" stack[depth] "\t" name
        while (match(rest, /[A-Za-z_][-A-Za-z0-9_:.]*[ \t]*=[ \t]*"[^"]*"/)) {
          a = substr(rest, RSTART, RLENGTH); rest = substr(rest, RSTART + RLENGTH)
          k = a; sub(/[ \t]*=.*/, "", k)
          v = a; sub(/^[^"]*"/, "", v); sub(/"$/, "", v)
          if (k ~ /^xmlns/) continue
          sub(/^android:/, "", k)
          out = out "\t" k "=" v
        }
        print out
        if (!selfclose) { depth++; stack[depth] = id }
      }
    }'
}

# aapt2 "dump xmltree" output -> flat records. Supports both the old "(type 0x12)0xffffffff"
# value style and the newer "=true" / "=42" / "=0x00000009" style.
flatten_aapt2() {
  awk '
    function hex2dec(h,   i, n) { h = tolower(h); sub(/^0x/, "", h); n = 0
      for (i = 1; i <= length(h); i++) n = n * 16 + index("0123456789abcdef", substr(h, i, 1)) - 1
      return n }
    /^[ ]*E: / {
      match($0, /^ */); ind = RLENGTH
      line = $0; sub(/^ *E: /, "", line); name = line; sub(/ .*/, "", name)
      if (cur) print rec
      while (sp > 0 && sind[sp] >= ind) sp--
      id++; parent = (sp > 0 ? sid[sp] : 0); sp++; sind[sp] = ind; sid[sp] = id
      rec = id "\t" parent "\t" name; cur = 1; next
    }
    /^[ ]*A: / && cur {
      line = $0; sub(/^ *A: /, "", line)
      eq = index(line, "="); k = substr(line, 1, eq - 1); v = substr(line, eq + 1)
      sub(/\(0x[0-9a-fA-F]+\)$/, "", k); sub(/^.*:/, "", k)
      if (v ~ /^"/) { v = substr(v, 2); q = index(v, "\""); if (q) v = substr(v, 1, q - 1) }
      else if (v ~ /^\(type 0x12\)/) { sub(/^\(type 0x12\)/, "", v); v = (hex2dec(v) == 0 ? "false" : "true") }
      else if (v ~ /^\(type 0x1[01]\)/) { sub(/^\(type 0x1[01]\)/, "", v); v = hex2dec(v) }
      else { sub(/ .*/, "", v) }
      rec = rec "\t" k "=" v; next
    }
    END { if (cur) print rec }'
}

if [ "$KIND" = "aab" ]; then
  if [ "${#BUNDLETOOL[@]}" -gt 0 ] && "${BUNDLETOOL[@]}" dump manifest --bundle="$INPUT" > "$MANIFEST_TXT" 2>/dev/null && grep -q '<manifest' "$MANIFEST_TXT"; then
    MANIFEST_SRC="bundletool dump manifest (base module)"
    flatten_xml < "$MANIFEST_TXT" > "$FLAT"
  elif [ -n "$AAPT2" ]; then
    # aapt2 can read a proto-format manifest if it sits in a zip next to resources.pb.
    mkdir -p "$TMP/proto/stage"
    unzip -qq -o "$INPUT" 'base/manifest/AndroidManifest.xml' 'base/resources.pb' -d "$TMP/proto" >/dev/null 2>&1 || true
    if [ -f "$TMP/proto/base/manifest/AndroidManifest.xml" ]; then
      cp "$TMP/proto/base/manifest/AndroidManifest.xml" "$TMP/proto/stage/AndroidManifest.xml"
      [ -f "$TMP/proto/base/resources.pb" ] && cp "$TMP/proto/base/resources.pb" "$TMP/proto/stage/resources.pb"
      if have zip && (cd "$TMP/proto/stage" && zip -q -r ../proto.apk .) 2>/dev/null &&
         "$AAPT2" dump xmltree --file AndroidManifest.xml "$TMP/proto/proto.apk" > "$MANIFEST_TXT" 2>/dev/null && grep -q 'E: manifest' "$MANIFEST_TXT"; then
        MANIFEST_SRC="aapt2 dump xmltree (proto manifest, base module)"
        flatten_aapt2 < "$MANIFEST_TXT" > "$FLAT"
      fi
    fi
  fi
else
  if [ -n "$AAPT2" ] && "$AAPT2" dump xmltree --file AndroidManifest.xml "$INPUT" > "$MANIFEST_TXT" 2>/dev/null && grep -q 'E: manifest' "$MANIFEST_TXT"; then
    MANIFEST_SRC="aapt2 dump xmltree"
    flatten_aapt2 < "$MANIFEST_TXT" > "$FLAT"
  elif [ -n "$APKANALYZER" ] && "$APKANALYZER" manifest print "$INPUT" > "$MANIFEST_TXT" 2>/dev/null && grep -q '<manifest' "$MANIFEST_TXT"; then
    MANIFEST_SRC="apkanalyzer manifest print"
    flatten_xml < "$MANIFEST_TXT" > "$FLAT"
  fi
fi
[ -f "$FLAT" ] || : > "$FLAT"
HAVE_MANIFEST=0
if [ -s "$FLAT" ] && awk -F'\t' '$3 == "manifest" { f = 1 } END { exit !f }' "$FLAT"; then HAVE_MANIFEST=1; fi

# fattr <tag> <key> : values of key for every record with that tag
fattr() {
  awk -F'\t' -v t="$1" -v k="$2=" '$3 == t { for (i = 4; i <= NF; i++) if (index($i, k) == 1) print substr($i, length(k) + 1) }' "$FLAT"
}
first() { head -n 1 || true; }

# Fallback when the manifest cannot be decoded: strings from the binary/proto XML.
MANIFEST_STRINGS="$TMP/manifest-strings.txt"
if [ "$KIND" = "aab" ]; then
  unzip -p "$INPUT" 'base/manifest/AndroidManifest.xml' 2>/dev/null | tr -d '\000' | extract_strings > "$MANIFEST_STRINGS"
else
  unzip -p "$INPUT" 'AndroidManifest.xml' 2>/dev/null | tr -d '\000' | extract_strings > "$MANIFEST_STRINGS"
fi

# ---------------------------------------------------------------------------------------------
# Package / versions
# ---------------------------------------------------------------------------------------------
section "PACKAGE"
TARGET=""
MINSDK=""
if [ "$HAVE_MANIFEST" = 1 ]; then
  info "manifest_source: $MANIFEST_SRC"
  PKG="$(fattr manifest package | first)"
  TARGET="$(fattr uses-sdk targetSdkVersion | first)"
  MINSDK="$(fattr uses-sdk minSdkVersion | first)"
  [ -n "$TARGET" ] || TARGET="$MINSDK"   # Android defaults targetSdk to minSdk
  info "package: ${PKG:--}"
  info "version_code: $(fattr manifest versionCode | first)"
  info "version_name: $(fattr manifest versionName | first)"
  info "min_sdk: ${MINSDK:--}"
  info "target_sdk: ${TARGET:--}"
  info "compile_sdk: $(fattr manifest compileSdkVersion | first)$(v="$(fattr manifest platformBuildVersionCode | first)"; [ -n "$v" ] && printf ' (platformBuildVersionCode %s)' "$v")"
  case "$TARGET" in
    ''|*[!0-9]*) info "INFO: targetSdkVersion not numeric/unknown" ;;
    *)
      if [ "$TARGET" -lt "$PLAY_TARGET_SDK_PREV" ]; then
        flag "POSSIBLE PLAY REJECTION: targetSdkVersion $TARGET is below API $PLAY_TARGET_SDK_PREV - new apps and updates are blocked (current requirement API $PLAY_TARGET_SDK; verify Play's target API policy)"
      elif [ "$TARGET" -lt "$PLAY_TARGET_SDK" ]; then
        flag "POSSIBLE PLAY REJECTION: targetSdkVersion $TARGET is below API $PLAY_TARGET_SDK, required for new apps and updates since 2026-08-31 (verify; Wear/TV/Auto differ)"
      fi ;;
  esac
else
  skip "manifest decoding: no usable bundletool/aapt2/apkanalyzer (the manifest is binary/proto XML). Using strings from the manifest instead - attribute values (targetSdk, exported, debuggable) cannot be determined."
  # Most frequent all-lowercase dotted name (component class names share the package prefix).
  pkg_guess="$(grep -oE '[a-z][a-z0-9_]*(\.[a-z0-9_]+)+' "$MANIFEST_STRINGS" | grep -vE '^(android|androidx|com\.android|com\.google\.android|schemas\.android\.com)(\.|$)' |
    sort | uniq -c | sort -rn | awk 'NR == 1 { print $2 }' || true)"
  info "package (guess from strings): ${pkg_guess:--}"
fi

# ---------------------------------------------------------------------------------------------
# Permissions
# ---------------------------------------------------------------------------------------------
# perm_note <permission> : "LEVEL|note". LEVEL is RESTRICTED (Play declaration / policy gate),
# SENSITIVE (runtime permission, Data safety disclosure) or blank.
perm_note() {
  case "$1" in
    android.permission.READ_SMS|android.permission.SEND_SMS|android.permission.RECEIVE_SMS|android.permission.RECEIVE_MMS|android.permission.RECEIVE_WAP_PUSH|android.permission.WRITE_SMS|android.permission.READ_CELL_BROADCASTS|android.permission.READ_CALL_LOG|android.permission.WRITE_CALL_LOG|android.permission.PROCESS_OUTGOING_CALLS)
      echo "RESTRICTED|SMS & Call Log policy: only default SMS/Phone/Assistant handlers or approved exceptions; Permissions Declaration Form required" ;;
    android.permission.QUERY_ALL_PACKAGES)
      echo "RESTRICTED|Package visibility policy: needs a core-purpose justification and declaration; prefer targeted <queries>" ;;
    android.permission.MANAGE_EXTERNAL_STORAGE)
      echo "RESTRICTED|All files access policy: only file managers, backup, antivirus, document apps etc.; declaration required" ;;
    android.permission.ACCESS_BACKGROUND_LOCATION)
      echo "RESTRICTED|Location permissions policy: background location declaration + video + prominent disclosure; core feature only" ;;
    android.permission.REQUEST_INSTALL_PACKAGES)
      echo "RESTRICTED|REQUEST_INSTALL_PACKAGES policy: only if installing packages is a core purpose; declaration required" ;;
    android.permission.READ_MEDIA_IMAGES|android.permission.READ_MEDIA_VIDEO)
      echo "RESTRICTED|Photo and Video Permissions policy: only apps whose core purpose needs broad media access; others must use the Android photo picker; declaration required" ;;
    android.permission.USE_EXACT_ALARM)
      echo "RESTRICTED|Exact alarm policy: USE_EXACT_ALARM only for alarm clock / calendar apps; declaration required" ;;
    android.permission.SCHEDULE_EXACT_ALARM)
      echo "SENSITIVE|special app access (denied by default for new installs on Android 14+); use only if exact timing is core" ;;
    android.permission.USE_FULL_SCREEN_INTENT)
      echo "RESTRICTED|Full-screen intent policy (Android 14+): only calling and alarm apps; Play Console declaration required" ;;
    android.permission.FOREGROUND_SERVICE_*)
      echo "RESTRICTED|Foreground service types: Play Console foreground service declaration (some types need a video); service must declare the matching foregroundServiceType" ;;
    android.permission.FOREGROUND_SERVICE)
      echo "SENSITIVE|foreground service (targetSdk 34+ also needs typed FOREGROUND_SERVICE_* permissions)" ;;
    com.google.android.gms.permission.AD_ID)
      echo "SENSITIVE|Advertising ID: must match the Play Console 'Advertising ID' declaration and Data safety form; restricted for apps targeting children (Families policy)" ;;
    android.permission.BIND_ACCESSIBILITY_SERVICE)
      echo "RESTRICTED|Accessibility API policy: prominent disclosure + declaration; not for non-accessibility automation" ;;
    android.permission.BIND_VPN_SERVICE)
      echo "RESTRICTED|VpnService policy: VPN must be core functionality; declaration required" ;;
    android.permission.BIND_DEVICE_ADMIN)
      echo "RESTRICTED|Device admin: only for enterprise/device-management/parental-control use cases" ;;
    android.permission.SYSTEM_ALERT_WINDOW)
      echo "SENSITIVE|draw over other apps; must be justified by user-facing functionality" ;;
    android.permission.PACKAGE_USAGE_STATS)
      echo "SENSITIVE|usage access (special app access); disclose in Data safety" ;;
    android.permission.READ_PHONE_STATE|android.permission.READ_PHONE_NUMBERS)
      echo "SENSITIVE|device/phone identifiers; Data safety disclosure; often added by old SDKs - remove if unused" ;;
    android.permission.health.*)
      echo "RESTRICTED|Health Connect: Play Console Health Connect declaration + privacy policy" ;;
    android.permission.ACCESS_FINE_LOCATION|android.permission.ACCESS_COARSE_LOCATION|android.permission.CAMERA|android.permission.RECORD_AUDIO|android.permission.READ_CONTACTS|android.permission.WRITE_CONTACTS|android.permission.GET_ACCOUNTS|android.permission.BODY_SENSORS|android.permission.BODY_SENSORS_BACKGROUND|android.permission.ACTIVITY_RECOGNITION|android.permission.READ_CALENDAR|android.permission.WRITE_CALENDAR|android.permission.BLUETOOTH_SCAN|android.permission.BLUETOOTH_CONNECT|android.permission.NEARBY_WIFI_DEVICES|android.permission.ACCESS_MEDIA_LOCATION|android.permission.READ_MEDIA_AUDIO|android.permission.READ_MEDIA_VISUAL_USER_SELECTED|android.permission.POST_NOTIFICATIONS|android.permission.CALL_PHONE|android.permission.ANSWER_PHONE_CALLS|android.permission.USE_BIOMETRIC|android.permission.UWB_RANGING)
      echo "SENSITIVE|runtime permission; disclose related data in the Data safety form" ;;
    android.permission.READ_EXTERNAL_STORAGE|android.permission.WRITE_EXTERNAL_STORAGE)
      echo "SENSITIVE|legacy storage permission (no effect on API 33+ / write on 30+); cap with maxSdkVersion" ;;
    *) echo "|" ;;
  esac
}

section "PERMISSIONS (merged manifest)"
PERMS="$TMP/perms.txt"
if [ "$HAVE_MANIFEST" = 1 ]; then
  awk -F'\t' '$3 == "uses-permission" || $3 == "uses-permission-sdk-23" {
      n = ""; m = ""
      for (i = 4; i <= NF; i++) { if (index($i, "name=") == 1) n = substr($i, 6); if (index($i, "maxSdkVersion=") == 1) m = substr($i, 15) }
      if (n != "") print n "\037" m "\037" $3 }' "$FLAT" | sort -u > "$PERMS"
  # Permissions required BY components (e.g. an accessibility service) count too.
  awk -F'\t' '$3 == "service" { for (i = 4; i <= NF; i++) if (index($i, "permission=") == 1) print substr($i, 12) "\037\037service-permission" }' "$FLAT" |
    grep -E 'BIND_(ACCESSIBILITY_SERVICE|VPN_SERVICE|DEVICE_ADMIN)' >> "$PERMS" || true
else
  grep -oE '(android\.permission|com\.google\.android\.gms\.permission|android\.permission\.health)\.[A-Z0-9_]+' "$MANIFEST_STRINGS" | sort -u | awk '{ print $0 "\037\037strings" }' > "$PERMS" || true
  info "INFO: permission names below were read from manifest strings (may include permissions the app defines or that components require)"
fi
info "count: $(wc -l < "$PERMS" | tr -d ' ')"
# Records use the ASCII unit separator (0x1F): with a tab IFS, bash would merge empty fields.
US="$(printf '\037')"
HAS_PERM() { cut -d "$US" -f1 "$PERMS" | grep -qx "$1"; }
while IFS="$US" read -r p maxsdk src; do
  [ -n "$p" ] || continue
  note="$(perm_note "$p")"; lvl="${note%%|*}"; txt="${note#*|}"
  extra=""
  [ -n "$maxsdk" ] && extra=" (maxSdkVersion=$maxsdk)"
  [ "$src" = "uses-permission-sdk-23" ] && extra="$extra (uses-permission-sdk-23)"
  [ "$src" = "service-permission" ] && extra="$extra (required by a <service>)"
  case "$lvl" in
    RESTRICTED) info "$p$extra"; flag "WARN: restricted permission $p$extra - $txt" ;;
    SENSITIVE)  info "$p$extra  - $txt" ;;
    *)          info "$p$extra" ;;
  esac
done < "$PERMS"
if HAS_PERM android.permission.ACCESS_BACKGROUND_LOCATION && ! HAS_PERM android.permission.ACCESS_FINE_LOCATION && ! HAS_PERM android.permission.ACCESS_COARSE_LOCATION; then
  flag "WARN: ACCESS_BACKGROUND_LOCATION without foreground location permission"
fi

# ---------------------------------------------------------------------------------------------
# Application flags
# ---------------------------------------------------------------------------------------------
section "APPLICATION FLAGS"
if [ "$HAVE_MANIFEST" = 1 ]; then
  app_attr() { fattr application "$1" | first; }
  dbg="$(app_attr debuggable)"; ctt="$(app_attr usesCleartextTraffic)"; nsc="$(app_attr networkSecurityConfig)"
  info "debuggable: ${dbg:-unset (false)}"
  info "usesCleartextTraffic: ${ctt:-unset (default false for targetSdk >= 28)}"
  info "networkSecurityConfig: ${nsc:-none}"
  info "allowBackup: $(app_attr allowBackup)"
  info "dataExtractionRules: $(app_attr dataExtractionRules)"
  info "requestLegacyExternalStorage: $(app_attr requestLegacyExternalStorage)"
  info "extractNativeLibs: $(app_attr extractNativeLibs)"
  info "queries_element: $(awk -F'\t' '$3 == "queries" { f = 1 } END { print (f ? "present" : "absent") }' "$FLAT")"
  if [ "$dbg" = "true" ]; then
    flag "POSSIBLE PLAY REJECTION: android:debuggable=true - Play Console rejects debuggable uploads (build the release variant)"
  fi
  if [ "$ctt" = "true" ]; then
    flag "WARN: usesCleartextTraffic=true - plain HTTP allowed app-wide; make sure no personal data is sent over HTTP (Data safety: encryption in transit)"
  elif [ -z "$ctt" ] && [ -n "$TARGET" ] && [ "$TARGET" -lt 28 ] 2>/dev/null; then
    info "INFO: targetSdk < 28 and usesCleartextTraffic unset -> cleartext allowed by default"
  fi
else
  skip "application flags (debuggable, usesCleartextTraffic, ...) need a decoded manifest"
  if grep -qx 'debuggable' "$MANIFEST_STRINGS"; then info "INFO: 'debuggable' attribute name present in manifest strings (value unknown)"; fi
fi

# Network security config contents (heuristic: look for cleartext / user CA trust).
NSC_FILES="$(grep -E '(^|/)res/xml/[^/]*network[^/]*\.xml$' "$LIST" || true)"
if [ -n "$NSC_FILES" ]; then
  while IFS= read -r nf; do
    info "network_security_config_file: $nf"
    body=""
    if [ "$KIND" = "apk" ] && [ -n "$AAPT2" ]; then
      body="$("$AAPT2" dump xmltree --file "$nf" "$INPUT" 2>/dev/null || true)"
    fi
    [ -n "$body" ] || body="$(unzip -p "$INPUT" "$nf" 2>/dev/null | tr -d '\000' | extract_strings)"
    if printf '%s\n' "$body" | grep -A2 'cleartextTrafficPermitted' | grep -qE '(=|^)"?true"?|^true$'; then
      flag "WARN: $nf permits cleartext traffic (cleartextTrafficPermitted=true)"
    fi
    if printf '%s\n' "$body" | grep -qE 'src="?user"?|^user$' && ! printf '%s\n' "$body" | grep -q 'debug-overrides'; then
      flag "WARN: $nf trusts user-installed CAs outside debug-overrides"
    fi
  done <<< "$NSC_FILES"
fi

# ---------------------------------------------------------------------------------------------
# Components: exported, foreground services
# ---------------------------------------------------------------------------------------------
COMPS="$TMP/comps.tsv"
: > "$COMPS"
if [ "$HAVE_MANIFEST" = 1 ]; then
  # tag, name, exported(effective yes/no), exported(raw), permission, launcher, fgsType, actions
  awk -F'\t' -v target="${TARGET:-0}" '
    { id = $1; par[id] = $2; tg[id] = $3; order[++n] = id
      for (i = 4; i <= NF; i++) { e = index($i, "="); a[id, substr($i, 1, e - 1)] = substr($i, e + 1) } }
    END {
      for (x = 1; x <= n; x++) { id = order[x]; p = par[id]
        if (tg[id] == "intent-filter") hasIF[p] = 1
        if (tg[p] == "intent-filter") { c = par[p]
          if (tg[id] == "action") { acts[c] = acts[c] (acts[c] == "" ? "" : ",") a[id, "name"]; if (a[id, "name"] == "android.intent.action.MAIN") isMain[c] = 1 }
          if (tg[id] == "category" && a[id, "name"] == "android.intent.category.LAUNCHER") isLauncher[c] = 1 }
      }
      for (x = 1; x <= n; x++) { id = order[x]; t = tg[id]
        if (t != "activity" && t != "activity-alias" && t != "service" && t != "receiver" && t != "provider") continue
        raw = ((id, "exported") in a) ? a[id, "exported"] : "unset"
        eff = "no"
        if (raw == "true") eff = "yes"
        else if (raw == "unset" && t != "provider" && hasIF[id] && target + 0 < 31) eff = "yes(implicit)"
        else if (raw == "unset" && t == "provider" && target + 0 < 17) eff = "yes(implicit)"
        perm = a[id, "permission"]
        if (t == "provider" && perm == "") perm = a[id, "readPermission"] a[id, "writePermission"]
        print t "\037" a[id, "name"] "\037" eff "\037" raw "\037" perm "\037" ((isMain[id] && isLauncher[id]) ? "launcher" : "") "\037" a[id, "foregroundServiceType"] "\037" acts[id]
      }
    }' "$FLAT" > "$COMPS"
fi

section "EXPORTED COMPONENTS"
if [ "$HAVE_MANIFEST" = 1 ]; then
  info "format: type | name | exported | permission | intent actions"
  nexp=0
  while IFS="$US" read -r t name eff raw perm launcher fgs acts; do
    case "$eff" in yes*) ;; *) continue ;; esac
    nexp=$((nexp + 1))
    info "$t | $name | $eff | ${perm:-none} | ${acts:--}${launcher:+ (launcher)}"
    if [ -z "$perm" ] && [ -z "$launcher" ]; then
      case "$t" in
        provider) flag "WARN: exported provider without read/write permission: $name - any app can query it" ;;
        service)  flag "WARN: exported service without permission: $name" ;;
        receiver) info "  INFO: exported receiver without permission (normal for system broadcasts like BOOT_COMPLETED; validate intent data)" ;;
        *)        info "  INFO: exported $t without permission (normal for deep links / share targets; validate incoming intents)" ;;
      esac
    fi
    if [ "$eff" = "yes(implicit)" ]; then
      info "  INFO: exported implicitly (intent-filter without android:exported, targetSdk < 31)"
    fi
  done < "$COMPS"
  [ "$nexp" -gt 0 ] || info "(none)"
else
  skip "exported-component analysis needs a decoded manifest"
fi

# FGS type flags (android.content.pm.ServiceInfo) -> names; name -> required permission suffix.
fgs_names() {
  local v="$1" out="" n
  if printf '%s' "$v" | grep -qE '^0[xX][0-9a-fA-F]+$'; then n=$((v))
  elif printf '%s' "$v" | grep -qE '^[0-9]+$'; then n="$v"
  else printf '%s' "$v"; return 0; fi   # already symbolic names, e.g. "location|dataSync"
  [ $((n & 1)) -ne 0 ] && out="$out|dataSync"
  [ $((n & 2)) -ne 0 ] && out="$out|mediaPlayback"
  [ $((n & 4)) -ne 0 ] && out="$out|phoneCall"
  [ $((n & 8)) -ne 0 ] && out="$out|location"
  [ $((n & 16)) -ne 0 ] && out="$out|connectedDevice"
  [ $((n & 32)) -ne 0 ] && out="$out|mediaProjection"
  [ $((n & 64)) -ne 0 ] && out="$out|camera"
  [ $((n & 128)) -ne 0 ] && out="$out|microphone"
  [ $((n & 256)) -ne 0 ] && out="$out|health"
  [ $((n & 512)) -ne 0 ] && out="$out|remoteMessaging"
  [ $((n & 1024)) -ne 0 ] && out="$out|systemExempted"
  [ $((n & 2048)) -ne 0 ] && out="$out|shortService"
  [ $((n & 4096)) -ne 0 ] && out="$out|fileManagement"
  [ $((n & 8192)) -ne 0 ] && out="$out|mediaProcessing"
  [ $((n & 1073741824)) -ne 0 ] && out="$out|specialUse"
  printf '%s' "${out#|}"
}
fgs_perm() {
  case "$1" in
    dataSync) echo DATA_SYNC ;; mediaPlayback) echo MEDIA_PLAYBACK ;; phoneCall) echo PHONE_CALL ;;
    location) echo LOCATION ;; connectedDevice) echo CONNECTED_DEVICE ;; mediaProjection) echo MEDIA_PROJECTION ;;
    camera) echo CAMERA ;; microphone) echo MICROPHONE ;; health) echo HEALTH ;;
    remoteMessaging) echo REMOTE_MESSAGING ;; systemExempted) echo SYSTEM_EXEMPTED ;;
    fileManagement) echo FILE_MANAGEMENT ;; mediaProcessing) echo MEDIA_PROCESSING ;; specialUse) echo SPECIAL_USE ;;
    *) echo "" ;;   # shortService needs no extra permission
  esac
}

section "FOREGROUND SERVICES"
if [ "$HAVE_MANIFEST" = 1 ]; then
  nfgs=0
  while IFS="$US" read -r t name eff raw perm launcher fgs acts; do
    [ "$t" = service ] && [ -n "$fgs" ] || continue
    nfgs=$((nfgs + 1))
    types="$(fgs_names "$fgs")"
    info "$name | foregroundServiceType=$types"
    for ty in $(printf '%s' "$types" | tr '|' ' '); do
      need="$(fgs_perm "$ty")"
      [ -n "$need" ] || continue
      if ! HAS_PERM "android.permission.FOREGROUND_SERVICE_$need"; then
        flag "WARN: service $name has foregroundServiceType=$ty but android.permission.FOREGROUND_SERVICE_$need is not declared (SecurityException on Android 14+ with targetSdk 34+)"
      fi
    done
  done < "$COMPS"
  [ "$nfgs" -gt 0 ] || info "(no services declare foregroundServiceType)"
  if HAS_PERM android.permission.FOREGROUND_SERVICE && [ "$nfgs" = 0 ] && [ "${TARGET:-0}" -ge 34 ] 2>/dev/null; then
    flag "WARN: FOREGROUND_SERVICE requested but no service declares foregroundServiceType (required for targetSdk 34+; Play FGS declaration)"
  fi
  if [ "$nfgs" -gt 0 ] && ! HAS_PERM android.permission.FOREGROUND_SERVICE; then
    flag "WARN: services declare foregroundServiceType but android.permission.FOREGROUND_SERVICE is missing"
  fi
else
  skip "foreground-service analysis needs a decoded manifest"
fi

# ---------------------------------------------------------------------------------------------
# SDK detection
# ---------------------------------------------------------------------------------------------
# "package-prefix<TAB>category<TAB>name" ; prefixes are dex type descriptors without the "L".
SDK_PREFIXES="$TMP/sdk-prefixes.tsv"
cat > "$SDK_PREFIXES" <<'EOF'
com/google/android/gms/ads/identifier	adid	Google Advertising ID client (reads AD_ID)
com/google/android/gms/ads	ads	Google Mobile Ads (AdMob / Ad Manager)
com/google/ads/mediation	ads	AdMob mediation adapter
com/facebook/ads	ads	Meta Audience Network
com/applovin	ads	AppLovin / MAX
com/unity3d/ads	ads	Unity Ads
com/unity3d/services	ads	Unity Ads services
com/ironsource	ads	ironSource / LevelPlay
com/vungle	ads	Liftoff Vungle
com/chartboost	ads	Chartboost
com/inmobi	ads	InMobi
com/mbridge	ads	Mintegral
com/bytedance/sdk/openadsdk	ads	Pangle
com/fyber	ads	DT Exchange (Fyber)
com/startapp	ads	Start.io
com/adcolony	ads	AdColony
com/amazon/device/ads	ads	Amazon Publisher Services
com/yandex/mobile/ads	ads	Yandex Mobile Ads
com/moloco	ads	Moloco
com/smaato	ads	Smaato
com/appsflyer	attribution	AppsFlyer
com/adjust/sdk	attribution	Adjust
io/branch	attribution	Branch
com/kochava	attribution	Kochava
com/singular/sdk	attribution	Singular
com/tenjin	attribution	Tenjin
com/google/firebase/analytics	analytics	Firebase / Google Analytics
com/google/android/gms/measurement	analytics	Google Analytics for Firebase (measurement)
com/facebook/appevents	analytics	Meta App Events (Facebook SDK)
com/facebook/FacebookSdk	analytics	Facebook SDK core
com/mixpanel	analytics	Mixpanel
com/amplitude	analytics	Amplitude
com/segment/analytics	analytics	Segment
com/flurry	analytics	Flurry
com/posthog	analytics	PostHog
com/microsoft/appcenter	analytics	App Center
com/yandex/metrica	analytics	AppMetrica
io/appmetrica	analytics	AppMetrica
com/clevertap	engagement	CleverTap
com/braze	engagement	Braze
com/moengage	engagement	MoEngage
com/onesignal	engagement	OneSignal
com/google/firebase/messaging	engagement	Firebase Cloud Messaging
com/google/firebase/crashlytics	crash	Firebase Crashlytics
io/sentry	crash	Sentry
com/bugsnag	crash	Bugsnag
com/datadog	crash	Datadog
com/newrelic	crash	New Relic
com/instabug	crash	Instabug
io/embrace	crash	Embrace
com/android/billingclient	payments	Google Play Billing
com/revenuecat	payments	RevenueCat
com/stripe	payments	Stripe
com/adapty	payments	Adapty
com/qonversion	payments	Qonversion
io/flutter	framework	Flutter
com/facebook/react	framework	React Native
expo/modules	framework	Expo
com/unity3d/player	framework	Unity
org/apache/cordova	framework	Cordova
com/getcapacitor	framework	Capacitor
org/godotengine	framework	Godot
com/google/android/play/core	other	Play Core
com/google/android/gms/location	other	Google Play services location
com/google/android/gms/auth	other	Google Sign-In / auth
com/google/mlkit	other	ML Kit
EOF

section "DETECTED SDKS (HEURISTIC)"
DEX_PKGS="$TMP/dex-pkgs.txt"
if [ "$KIND" = "aab" ]; then dexglob='*/dex/classes*.dex'; else dexglob='classes*.dex'; fi
ndex="$(grep -cE "$( [ "$KIND" = aab ] && echo '^[^/]+/dex/classes[0-9]*\.dex$' || echo '^classes[0-9]*\.dex$')" "$LIST" || true)"
info "dex_files: $ndex"
# Dex string pools hold type descriptors like "Lcom/appsflyer/AppsFlyerLib;". The ULEB128
# length byte before each string can be printable, so do not anchor at line start.
unzip -p "$INPUT" "$dexglob" 2>/dev/null | extract_strings |
  grep -oE 'L[a-z][a-z0-9_]*(/[A-Za-z0-9_$]+){1,6};' | sed -E 's/^L//; s/;$//' | sort -u > "$DEX_PKGS" || true
info "unique_class_descriptors: $(wc -l < "$DEX_PKGS" | tr -d ' ')"
SDK_HITS="$TMP/sdk-hits.tsv"; : > "$SDK_HITS"
while IFS="$(printf '\t')" read -r pre cat name; do
  [ -n "$pre" ] || continue
  if grep -q "^$pre" "$DEX_PKGS" 2>/dev/null; then printf '%s\t%s\t%s\n' "$cat" "$name" "$pre" >> "$SDK_HITS"; fi
done < "$SDK_PREFIXES"
# Manifest meta-data names also reveal SDKs (e.g. com.google.android.gms.ads.APPLICATION_ID).
if [ "$HAVE_MANIFEST" = 1 ]; then
  if fattr meta-data name | grep -q '^com\.google\.android\.gms\.ads\.APPLICATION_ID$'; then
    grep -q 'Google Mobile Ads' "$SDK_HITS" || printf 'ads\tGoogle Mobile Ads (AdMob / Ad Manager)\tmeta-data APPLICATION_ID\n' >> "$SDK_HITS"
  fi
  if fattr meta-data name | grep -q '^com\.facebook\.sdk\.ApplicationId$'; then
    grep -q 'Facebook SDK' "$SDK_HITS" || printf 'analytics\tFacebook SDK core\tmeta-data com.facebook.sdk.ApplicationId\n' >> "$SDK_HITS"
  fi
fi
if [ -s "$SDK_HITS" ]; then
  info "format: category | sdk | evidence"
  sort "$SDK_HITS" | awk -F'\t' '{ print $1 " | " $2 " | " $3 }'
else
  info "(no known SDK package prefixes found - code may be obfuscated, or no dex present)"
fi
HAS_ADS=0; grep -qE '^(ads|attribution)[[:space:]]' "$SDK_HITS" && HAS_ADS=1
if [ "$HAVE_MANIFEST" = 1 ]; then
  if [ "$HAS_ADS" = 1 ] && ! HAS_PERM com.google.android.gms.permission.AD_ID && [ "${TARGET:-0}" -ge 33 ] 2>/dev/null; then
    flag "WARN: ads/attribution SDK detected but com.google.android.gms.permission.AD_ID is not in the merged manifest - the advertising ID will read as zeros (fine only if intentional, e.g. a children's app); keep the Play Console Advertising ID declaration consistent"
  fi
  if [ "$HAS_ADS" = 0 ] && HAS_PERM com.google.android.gms.permission.AD_ID; then
    flag "WARN: AD_ID permission present but no ads/attribution SDK detected - declare Advertising ID use in Play Console/Data safety, or remove it (tools:node=\"remove\") if unused"
  fi
fi
if [ "$HAS_ADS" = 1 ]; then
  info "INFO: ads/attribution SDKs: Data safety must disclose device IDs/usage data; Families policy limits SDKs in apps for children"
fi

info ""
info "-- library version markers (META-INF/*.version) --"
if [ "$KIND" = "aab" ]; then vglob='^[^/]+/root/META-INF/[^/]+\.version$'; else vglob='^META-INF/[^/]+\.version$'; fi
VERFILES="$(grep -E "$vglob" "$LIST" || true)"
if [ -n "$VERFILES" ]; then
  info "count: $(printf '%s\n' "$VERFILES" | wc -l | tr -d ' ')"
  printf '%s\n' "$VERFILES" | head -n 400 | while IFS= read -r vf; do
    lib="$(basename "$vf" .version)"; lib="$(printf '%s' "$lib" | sed 's/_/:/')"   # group_artifact -> group:artifact
    ver="$(unzip -p "$INPUT" "$vf" 2>/dev/null | head -n 1 | tr -d '\r\n' || true)"
    info "  $lib = ${ver:-?}"
  done
  if printf '%s\n' "$VERFILES" | grep -q 'com\.google\.android\.play_core\.version$'; then
    flag "WARN: legacy monolithic Play Core library (com.google.android.play:core) found - incompatible with targetSdk 34+ (broadcast receiver crash); migrate to play:app-update / review / feature-delivery"
  fi
else
  info "(none - R8/packaging may strip them)"
fi
info ""
info "-- SDK .properties markers --"
if [ "$KIND" = "aab" ]; then pglob='^[^/]+/root/[^/]+\.properties$'; else pglob='^[^/]+\.properties$'; fi
PROPFILES="$(grep -E "$pglob" "$LIST" || true)"
if [ -n "$PROPFILES" ]; then
  printf '%s\n' "$PROPFILES" | head -n 200 | while IFS= read -r pf; do
    kv="$(unzip -p "$INPUT" "$pf" 2>/dev/null | grep -E '^(version|client)=' | tr '\n' ' ' || true)"
    info "  $(basename "$pf"): ${kv:-?}"
  done
else
  info "(none)"
fi

# ---------------------------------------------------------------------------------------------
# Native libraries: ABIs, 64-bit, 16 KB page size
# ---------------------------------------------------------------------------------------------
# elf_min_load_align <file> : prints "<bits> <min p_align of PT_LOAD>" or nothing if not ELF.
# Reads the ELF header and program headers with od (little-endian, which every Android ABI is).
elf_min_load_align() {
  local f="$1" magic cls phoff phentsize phnum
  magic="$(od -An -tx1 -N4 "$f" 2>/dev/null | tr -d ' \n')"
  [ "$magic" = "7f454c46" ] || return 0
  cls="$(od -An -tu1 -j4 -N1 "$f" | tr -d ' \n')"
  if [ "$cls" = 2 ]; then
    phoff="$(od -An -tu4 -j32 -N8 "$f" | awk 'NF { printf "%.0f", $1 + $2 * 4294967296; exit }')"
    phentsize="$(od -An -tu2 -j54 -N2 "$f" | tr -d ' \n')"
    phnum="$(od -An -tu2 -j56 -N2 "$f" | tr -d ' \n')"
    # Elf64_Phdr: p_type = word 0, p_align = words 12..13 (u4 words)
    od -An -v -tu4 -j "$phoff" -N $((phentsize * phnum)) "$f" | tr -s ' \n' '\n\n' | grep -v '^$' |
      awk -v w=$((phentsize / 4)) '{ v[NR - 1] = $1 } END {
        min = -1; for (k = 0; k * w < NR; k++) { b = k * w; if (v[b] == 1) { al = v[b + 12] + v[b + 13] * 4294967296; if (min < 0 || al < min) min = al } }
        printf "64 %.0f\n", min }'
  elif [ "$cls" = 1 ]; then
    phoff="$(od -An -tu4 -j28 -N4 "$f" | tr -d ' \n')"
    phentsize="$(od -An -tu2 -j42 -N2 "$f" | tr -d ' \n')"
    phnum="$(od -An -tu2 -j44 -N2 "$f" | tr -d ' \n')"
    # Elf32_Phdr: p_type = word 0, p_align = word 7
    od -An -v -tu4 -j "$phoff" -N $((phentsize * phnum)) "$f" | tr -s ' \n' '\n\n' | grep -v '^$' |
      awk -v w=$((phentsize / 4)) '{ v[NR - 1] = $1 } END {
        min = -1; for (k = 0; k * w < NR; k++) { b = k * w; if (v[b] == 1) { al = v[b + 7]; if (min < 0 || al < min) min = al } }
        printf "32 %.0f\n", min }'
  fi
}

section "NATIVE LIBRARIES"
if [ "$KIND" = "aab" ]; then libre='^[^/]+/lib/[^/]+/[^/]+\.so$'; else libre='^lib/[^/]+/[^/]+\.so$'; fi
LIBS="$TMP/libs.txt"
grep -E "$libre" "$LIST" | sort > "$LIBS" || true
if [ ! -s "$LIBS" ]; then
  info "(no native libraries - 64-bit and 16 KB page-size requirements do not apply)"
else
  ABIS="$(sed -E 's#^([^/]+/)?lib/([^/]+)/.*#\2#' "$LIBS" | sort -u | tr '\n' ' ')"
  info "abis: $ABIS"
  info "library_count: $(wc -l < "$LIBS" | tr -d ' ')"
  has_abi() { case " $ABIS " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
  if has_abi armeabi-v7a && ! has_abi arm64-v8a; then
    flag "POSSIBLE PLAY REJECTION: armeabi-v7a native code without arm64-v8a - Play's 64-bit requirement"
  fi
  if has_abi x86 && ! has_abi x86_64; then
    flag "WARN: x86 native code without x86_64 (64-bit requirement)"
  fi
  if has_abi armeabi-v7a && has_abi arm64-v8a; then
    missing64="$(
      sed -nE 's#^([^/]+/)?lib/armeabi-v7a/(.*)#\2#p' "$LIBS" | sort -u > "$TMP/l32"
      sed -nE 's#^([^/]+/)?lib/arm64-v8a/(.*)#\2#p' "$LIBS" | sort -u > "$TMP/l64"
      comm -23 "$TMP/l32" "$TMP/l64" | tr '\n' ' '
    )"
    [ -z "$missing64" ] || flag "WARN: libraries present for armeabi-v7a but missing for arm64-v8a: $missing64"
  fi

  info ""
  info "-- 16 KB page-size alignment of ELF LOAD segments (64-bit ABIs must be >= 16384) --"
  info "format: library | elf_class | min_load_align | status"
  mkdir -p "$TMP/so"
  bad16=0
  while IFS= read -r lib; do
    out="$TMP/so/lib.so"
    unzip -p "$INPUT" "$lib" > "$out" 2>/dev/null || { info "$lib | ? | ? | unreadable"; continue; }
    res="$(elf_min_load_align "$out")"
    rm -f "$out"
    if [ -z "$res" ]; then info "$lib | - | - | not ELF"; continue; fi
    bits="${res%% *}"; al="${res#* }"
    if [ "$bits" = 64 ]; then
      if [ "$al" -ge 16384 ] 2>/dev/null; then st="ok"; else st="NOT 16KB-aligned"; bad16=$((bad16 + 1)); fi
    else
      st="32-bit (16KB not required)"
    fi
    info "$lib | $bits | $al | $st"
  done < "$LIBS"
  if [ "$bad16" -gt 0 ]; then
    flag "POSSIBLE PLAY REJECTION: $bad16 64-bit native librar(y/ies) with LOAD segments aligned below 16 KB - apps targeting Android 15+ must support 16 KB page sizes (rebuild with NDK r28+ / -Wl,-z,max-page-size=16384, update the SDKs that ship them)"
  fi

  if [ "$KIND" = "apk" ]; then
    info ""
    info "-- zip alignment of uncompressed .so files (APK only) --"
    stored="$(unzip -v "$INPUT" 2>/dev/null | awk '$2 == "Stored" && $NF ~ /^lib\/.*\.so$/ { n++ } END { print n + 0 }')"
    info "uncompressed_so_files: $stored"
    if [ "$stored" = 0 ]; then
      info "INFO: all .so files are compressed (extracted at install) - zip alignment not relevant"
    elif [ -n "$ZIPALIGN" ]; then
      if "$ZIPALIGN" -c -P 16 4 "$INPUT" >/dev/null 2>&1; then
        info "zipalign -c -P 16: OK"
      else
        flag "POSSIBLE PLAY REJECTION: zipalign -c -P 16 failed - uncompressed .so files are not 16 KB zip-aligned (AGP 8.5.1+ aligns automatically)"
        "$ZIPALIGN" -c -v -P 16 4 "$INPUT" 2>/dev/null | grep -E '\.so.*BAD' | head -n 10 | sed 's/^/  /' || true
      fi
    else
      skip "zipalign: 16 KB zip alignment of uncompressed .so files not checked"
    fi
  else
    info "INFO: AAB - zip alignment is applied when Play generates APKs; only ELF alignment matters here"
  fi
fi

# ---------------------------------------------------------------------------------------------
# Signing + bundle metadata
# ---------------------------------------------------------------------------------------------
section "SIGNING AND METADATA"
SIGFILES="$(grep -E '^META-INF/[^/]+\.(RSA|DSA|EC)$' "$LIST" || true)"
if [ "$KIND" = "apk" ] && [ -n "$APKSIGNER" ] && [ "$HAVE_JAVA" = 1 ]; then
  certs="$("$APKSIGNER" verify --print-certs "$INPUT" 2>&1 || true)"
  printf '%s\n' "$certs" | grep -E 'Signer #[0-9]+ certificate DN|DOES NOT VERIFY|ERROR' | head -n 5 | sed 's/^/  /' || true
  if printf '%s\n' "$certs" | grep -q 'CN=Android Debug'; then
    flag "POSSIBLE PLAY REJECTION: APK is signed with the Android debug certificate"
  fi
  if printf '%s\n' "$certs" | grep -q 'DOES NOT VERIFY'; then info "INFO: APK signature does not verify (unsigned or tampered)"; fi
else
  [ "$KIND" = "apk" ] && skip "apksigner (needs java): APK signer certificate not inspected; falling back to META-INF scan"
  if [ -n "$SIGFILES" ]; then
    info "jar_signature_files: $(printf '%s' "$SIGFILES" | tr '\n' ' ')"
    debug_cert=0
    while IFS= read -r sf; do
      if unzip -p "$INPUT" "$sf" 2>/dev/null | tr -d '\000' | extract_strings | grep -q 'Android Debug'; then debug_cert=1; fi
    done <<< "$SIGFILES"
    if [ "$debug_cert" = 1 ]; then
      flag "POSSIBLE PLAY REJECTION: signed with the Android debug certificate (CN=Android Debug)"
    fi
  else
    if [ "$KIND" = "aab" ]; then
      info "INFO: no JAR signature in the bundle - Play requires the upload to be signed with your upload key"
    else
      info "INFO: no v1 (JAR) signature files; v2+/APK Signature Scheme blocks need apksigner to inspect"
    fi
  fi
fi
if [ "$KIND" = "aab" ]; then
  info "modules: $(grep -E '^[^/]+/manifest/AndroidManifest\.xml$' "$LIST" | cut -d/ -f1 | tr '\n' ' ')"
  meta="$(grep -E '^BUNDLE-METADATA/' "$LIST" || true)"
  if [ -n "$meta" ]; then
    info "BUNDLE-METADATA:"
    printf '%s\n' "$meta" | sed 's/^/  /'
    printf '%s\n' "$meta" | grep -q 'com.android.tools.build.obfuscation/proguard.map' && info "INFO: R8 mapping file included (deobfuscated crash reports in Play Console)"
  else
    info "BUNDLE-METADATA: (none)"
  fi
  grep -q '^BundleConfig.pb$' "$LIST" && info "BundleConfig.pb: present"
fi

# ---------------------------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------------------------
section "SUMMARY"
info "possible_play_rejections: $(grep -c '^POSSIBLE PLAY REJECTION:' "$FLAGS" || true)"
info "warnings: $(grep -c '^WARN:' "$FLAGS" || true)"
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
