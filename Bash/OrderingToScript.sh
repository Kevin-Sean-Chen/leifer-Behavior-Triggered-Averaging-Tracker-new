#!/bin/bash

ordering=$1

case $ordering in
    0)
		echo delete_tracks
		;;

    1)
        echo track_image_directory
        ;;
     
    2)
        echo find_centerlines
        ;;

    3)
        echo auto_resolve_problems
        ;;

    4)
        echo calculate_spectra
        ;;

    5)
        echo calculate_embeddings
        ;;

	6)
        echo calculate_behaviors
        ;;

	7)
        echo plot_image_directory
        ;;

    8)
        echo more_than_max
        ;;
        
    *)
        echo 0
        ;;
esac

