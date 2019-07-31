#! /bin/sh
echo "Transmission  $TR_APP_VERSION finished downloading \"$TR_TORRENT_NAME\" list $TR_TORRENT_ID in $TR_TORRENT_DIR on $TR_TIME_LOCALTIME" > /config/test1.log
# DOWNPATH=$TR_TORRENT_DIR
#DOWNPATH="~/data/jav/MEYD-486"
#BASEDIR="/data/video"
BASEDIR=$TR_TORRENT_DIR
subdir=$TR_TORRENT_DIR

function sub(){
    for file in "$1"/*
    do
        if [[ -d "$file" && "${file:0-2}" != "_h5ai" && "${file:0-2}" != "__" ]]; then
            sub "$file"
        else
            if [[ "${file##*.}" == "ass" || "${file##*.}" == "srt" ]]; then
                filenotype="${file%.*}"
                if [[ ! -f "${filenotype}.vtt" ]]; then
                    ffmpeg -i "$file" "${filenotype}.vtt"
                    # rm "$file"
                fi
            fi
        fi
    done
}
sub "$subdir"

echo "sub finish"

function hlsfile(){
	file="$1"
	if [[ "${file##*.}" == "mp4" || "${file##*.}" == "mkv" || "${file##*.}" == "ts"|| "${file##*.}" == "avi" ]]; then
		filename="${file##*/}"
		m3u8dir="${file%/*}/__${filename}__"
		if [[ ! -d "${m3u8dir}" && ! -f "${file}.aria2" ]]; then
			mkdir -p "${m3u8dir}"
			ffmpeg -i "${file}" -c copy -bsf:v h264_mp4toannexb -hls_time 6 -hls_list_size 0 -hls_segment_filename "${m3u8dir}/%04d.ts" "${m3u8dir}/video.m3u8" > /dev/null 2>&1
			# echo 'Rikka' > "${file}"
		fi
	fi
}

function scandir(){
	for dirfile in "$1"/*
	
	do
		if [[ -d "${dirfile}" && "${dirfile:0-5}" != "_h5ai" && "${dirfile:0-2}" != "__" ]]; then
			scandir "${dirfile}"
		else
		echo "${dirfile}"
			hlsfile "${dirfile}"
		fi
	done
}
scandir "${BASEDIR}"

echo "hls finish"