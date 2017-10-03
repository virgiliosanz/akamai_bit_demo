#!/bin/sh

# https://ac.akamai.com/community/teams/gss/global-services/gcs/blog/2017/07/28/4k-hls-ingest-assisted-by-ias-with-ffmpeg-one-liner

# --- VIDEO Recommendations ----
#                   240p       360p        480p        720p        1080p
# Resolution      426 x 240   640 x 360   854x480     1280x720    1920x1080
# Video Bitrates
# Maximum         700 Kbps    1000 Kbps   2000 Kbps   4000 Kbps   6000 Kbps
# Recommended     400 Kbps    750 Kbps    1000 Kbps   2500 Kbps   4500 Kbps
# Minimum         300 Kbps    400 Kbps    500 Kbps    1500 Kbps   3000 Kbps

# --- AUDIO Recommendations ----
# Resolution	Audio Bit Rate	Compression
# Original	192 kbps	AAC
# 1080p		192 kbps	AAC
# 720p		192 kbps	AAC
# 480p		128 kbps	AAC
# 360p		128 kbps	AAC
# 240p		64 kbps		MP3

VIDEO_IN_FILE="../bbb_sunflower_2160p_30fps_normal.mp4"

VIDEO_BITRATE="2600K"
VIDEO_MAX_BITRATE="4000K"
AUDIO_BITRATE="192K"
PROFILE=baseline
SEGMENT_SIZE_SECS=2
SEGMENT_NUMBER=3
RESOLUTION=1280x720

# ias
AKAMAI_EP="http://192.168.33.13:1234/p-ep572083.i.akamaientrypoint.net/572083/bittest1/master.m3u8"

# No ias
#AKAMAI_EP="http://p-ep572083.i.akamaientrypoint.net/572083/MSL_4_2/playlist.m3u8"


# List devices
# fmpeg -f avfoundation -list_devices true -i "f"

# HLS Using Webcam
ffmpeg -stream_loop -1 \
    -f avfoundation \
    -framerate 30 \
    -s ${RESOLUTION} \
    -video_device_index 0 -i "default" \
    -pix_fmt uyvy422 \
    -allow_sw 1 \
    -vcodec h264_videotoolbox \
    -realtime true \
    -profile:v ${PROFILE} \
    -vb ${VIDEO_BITRATE} \
    -bufsize ${VIDEO_BITRATE} \
    -maxrate ${VIDEO_MAX_BITRATE} \
    -acodec aac \
    -ab ${AUDIO_BITRATE} \
    -vf drawbox="x=0:y=0:width=iw/4:height=ih/20:color=black:t=max",drawtext="text='%{localtime}':x=25:y=10:fontfile=/Library/Fonts/Times New Roman Bold.ttf:fontsize=32:fontcolor=#ffa500" \
    -f hls -hls_allow_cache 1 -hls_time ${SEGMENT_SIZE_SECS} -hls_list_size ${SEGMENT_NUMBER} \
    -hls_flags program_date_time -hls_playlist_type event \
    -use_localtime 1 \
    -method PUT ${AKAMAI_EP}


# HLS 4k
#ffmpeg -stream_loop -1 \
#	-i ${VIDEO_IN_FILE} \
#        -pix_fmt uyvy422 \
#        -allow_sw 1 \
#	-vcodec h264_videotoolbox \
#	-realtime true \
#	-profile:v high \
#	-vb 8000k -bufsize 8000k -maxrate 10000k \
#	-acodec aac \
#       -f hls -hls_allow_cache 1 -hls_time ${SEGMENT_SIZE_SECS} -hls_list_size ${SEGMENT_NUMBER} \
#	-hls_flags program_date_time -hls_playlist_type event \
#	-use_localtime 1 \
#        -vf drawbox="x=0:y=0:width=iw/4:height=ih/20:color=black:t=max",drawtext="text='%{localtime}':x=25:y=10:fontfile=/Library/Fonts/Times New Roman Bold.ttf:fontsize=96:fontcolor=#ffa500" \
#	-method PUT ${AKAMAI_EP}
