#!/usr/bin/env bash

set -e
set -x

infile="$1"

if [[ ! -f "${infile}" ]]; then
  echo >&2 "File not found: ${infile}"
  exit 1
fi

outdir="icons" # output directory

windows_ico_sizes=(16 24 32 48 64 256) # https://docs.microsoft.com/en-gb/windows/desktop/uxguide/vis-icons
macos_icns_sizes=(16 32 48 128 256 512 1024) # https://en.wikipedia.org/wiki/Apple_Icon_Image_format
freedesktop_common_sizes=(16 22 24 32 48 128 256 512)

other_desired_sizes=(2048) # edit this if you want more sizes

all_sizes=("${windows_ico_sizes[@]}" "${macos_icns_sizes[@]}" \
  "${freedesktop_common_sizes[@]}" "${other_desired_sizes[@]}")

# sort the list of sizes and ensure each size only appears once in list
IFS=$'\n' all_sizes=($(sort --unique --version-sort <<<"${all_sizes[*]}")); unset IFS

echo "export sizes: ${all_sizes[*]}"

rm -rf "${outdir}"
mkdir -p "${outdir}"

# Convert text to paths to remove font dependency
# Export as plain SVG (reduces filesize) for systems that support SVG icons
tmpfile="${outdir}/tmp.svg"
outfile="${outdir}/icon.svg"
inkscape -z "${infile}" \
  --export-text-to-path \
  --export-plain-svg "${tmpfile}"
scour "${tmpfile}" "${outfile}" # optimize the SVG and embed external resources
rm -f "${tmpfile}"

# Convert to PNG for systems that don't support vector icons
for size in "${all_sizes[@]}"; do
  tmpfile="${outdir}/tmp.png"
  outfile="${outdir}/icon-${size}.png"
  inkscape -z "${infile}" \
    --export-width ${size} \
    --export-height ${size} \
    --export-png "${tmpfile}"
  pngcrush -rem allb "${tmpfile}" "${outfile}" # optimize the PNG
  rm -f "${tmpfile}"
done

# Convert PNG to ICO for Windows
ico_input_files=()
for size in "${windows_ico_sizes[@]}"; do
  ico_input_files+=("${outdir}/icon-${size}.png")
done
convert "${ico_input_files[@]}" "${outdir}/icon.ico"

# Convert PNG to ICNS for macOS
icns_input_files=()
for size in "${macos_icns_sizes[@]}"; do
  icns_input_files+=("${outdir}/icon-${size}.png")
done
png2icns "${outdir}/icon.icns" "${icns_input_files[@]}"

rm -f icons.zip
zip icons.zip -r "${outdir}"
