#!/bin/sh
case "$1" in
    pre)
        # Hentikan fprintd sebelum sleep agar tidak terjadi error USB busy / hang
        systemctl stop fprintd.service
        ;;
    post)
        # Reset dan restart fprintd setelah bangun agar sensor siap digunakan
        systemctl restart fprintd.service
        ;;
esac
