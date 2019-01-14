#!/bin/bash

ordering=$1

case $ordering in
    0)
		echo delete_tracks
		;;

    1)
        echo unzip_data
        ;;

    2)
        echo track_image_directory
        ;;
     
    3)
        echo find_centerlines
        ;;

    4)
        echo auto_resolve_problems
        ;;

    5)
        echo calculate_spectra
        ;;

    6)
        echo calculate_embeddings
        ;;

	7)
        echo calculate_behaviors
        ;;

	8)
        echo plot_image_directory
        ;;

    9)
        echo zip_data
        ;;

    10)
        echo more_than_max
        ;;
        
    *)
        echo 0
        ;;
esac

