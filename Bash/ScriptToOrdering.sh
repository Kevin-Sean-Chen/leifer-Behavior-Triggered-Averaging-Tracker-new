#!/bin/bash

script_name=$1

case "$script_name" in
    delete_tracks)
		echo 0
		;;

    track_image_directory)
        echo 1
        ;;
     
    find_centerlines)
        echo 2
        ;;

    auto_resolve_problems)
        echo 3
        ;;

    calculate_spectra)
        echo 4
        ;;

	calculate_behaviors)
        echo 5
        ;;

	plot_image_directory)
        echo 6
        ;;

    max)
        echo 6
        ;;
        
    *)
        echo -1
        ;;
esac

