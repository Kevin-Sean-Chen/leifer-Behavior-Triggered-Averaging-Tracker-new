#!/bin/bash

script_name=$1

case "$script_name" in
    delete_tracks)
		echo 0
		;;

    unzip_data)
        echo 1
        ;;

    track_image_directory)
        echo 2
        ;;
     
    find_centerlines)
        echo 3
        ;;

    auto_resolve_problems)
        echo 4
        ;;

    calculate_spectra)
        echo 5
        ;;

    calculate_embeddings)
        echo 6
        ;;

	calculate_behaviors)
        echo 7
        ;;

	plot_image_directory)
        echo 8
        ;;

    zip_data)
        echo 9
        ;;

    max)
        echo 9
        ;;
        
    *)
        echo -1
        ;;
esac

