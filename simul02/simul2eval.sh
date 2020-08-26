#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/
# https://www.linux.com/training-tutorials/writing-simple-bash-script/
# http://tldp.org/LDP/Bash-Beginners-Guide/html/
# https://bash.cyberciti.biz/guide/For_loop


# Change variables to perform operation
declare CHANGE_FILENAMES=false
declare INSERT_COLUMNS=false
declare MERGE_TABLES=true

# pathThs=("./M2/" "./M4/" "./M8/" "./MG2/")
thinnings=("M2" "M4" "M8" "MG2")
vars=("AB" "Dm" "Dq" "Hdom" "Itinerario" "VC" "VolAprov")

if [ ${CHANGE_FILENAMES} = true ]
then
	for thinning in "${thinnings[@]}"
	do
		echo '                  thinning' ${thinning}
		pthVar="./"${thinning}"/"
		files=(`ls ${pthVar// /}*.txt | grep -i ${pthVar// /}`)
		for file in "${files[@]}"
		do
			filecsv="$(echo "$file" | sed s/txt/csv/)"
			echo "copying" ${file} "to" ${filecsv}
			csvtk space2tab ${file} -o ${filecsv}
			rm ${file}
		done
		files=(`ls ${pthVar// /}*.csv | grep -i ${pthVar// /}`)
		for file in "${files[@]}"
		do
			if [[ "$file" =~ "aprovechado" ]]; then
				mv "${file}" "$(echo "$file" | sed s/VC/VolAprov/)";
			fi
		done
	done
fi

if [ ${INSERT_COLUMNS} = true ]
then

for thinning in "${thinnings[@]}"
do
	echo '                  thinning' ${thinning}
	for var in "${vars[@]}"
	do
		echo '   var' ${var}
		pthVar="./"${thinning}"/"${var}
		echo ${pthVar}
		files=(`ls ${pthVar// /}*.csv | grep -i ${pthVar// /}`)
		for file in "${files[@]}"
		do
			znce=$(echo $file | tr -cd '[[:digit:]]')
			# if [[ "$file" =~ ".0." ]]; then
			# 	zona=0;
			# else
			# 	zona=1;
			# fi
			zon="${znce:1:1}"
			cal="${znce:2:2}"
			echo 'thinning' ${thinning} ' var' ${var} 'file' ${file} 'zona' ${zona} 'zon' ${zon} 'cal' ${cal} 'znce' ${znce}
			# space2tab: converts space delimited format to CSV
			csvtk mutate2 ${file} -t -e " \$1 > 0 ? '$thinning' : '$thinning' " -n thinning > ${file}.out
			csvtk mutate2 ${file}.out -t -e " \$1 > 0 ? '$var' :'$var' " -n varname > ${file}
			csvtk mutate2 ${file} -t -e " \$1 > 0 ? '$zon' :'$zon' " -n zone > ${file}.out
			csvtk mutate2 ${file}.out -t -e " \$1 > 0 ? '$cal' :'$cal' " -n cal > ${file}
			rm ${file}.out
			# #echo "Merging ${#filesForTable[@]} files for table ${var}"
			#csvtk concat -k ${filesForTable[@]} > "./joint/${var// /}.txt"
		done
	done
done

fi

#thinnings=("M2" "M4")
#vars=("AB")

if [ ${MERGE_TABLES} = true ]
	then
	for var in "${vars[@]}"
	do
	echo '               var' ${var}
	files=()
		for thinning in "${thinnings[@]}"
		do
			pthVar="./"${thinning}"/"${var}
			echo ${pthVar}
			files+=(`ls ${pthVar// /}*.csv | grep -i ${pthVar// /}`)
		done
		echo "Merging ${#files[@]} files for table ${var}"
		csvtk concat -k ${files[@]} > "./joint/${var// /}.csv"
	done
fi